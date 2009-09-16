/*
This file is part of i5/OS Programmer's Toolkit.

Copyright (C) 2009  Junlei Li (李君磊).

i5/OS Programmer's Toolkit is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

i5/OS Programmer's Toolkit is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with i5/OS Programmer's Toolkit.  If not, see <http://www.gnu.org/licenses/>.
*/
/**
 * @file mic.cpp
 *
 */

# include <mic.hpp>

# include <unistd.h>
# include <fcntl.h>

# ifdef __OS400__
#   include <qprcrtpg.h>
#   include <qusec.h>
#   include <qmhrtvm.h>
#   include <qmhsndpm.h>
#   include <qusrjobi.h>
#   include <quslspl.h>
#   include <quscrtus.h>
#   include <qusptrus.h>
#   include <recio.h>
# else
#   include <os400-mock.h>
# endif

/// EMI/MIC version number, used internally
unsigned short mic_version_ = 0x0002;

/**
 * map from builtin-name to builtin-number
 *
 * entry format:
 *  - builtin name, char(30)
 *  - builtin number, char(4), nnnn, 表示ubin(2)
 */
char builtin_name_number_map_[] = {

  "MEMCPY                        0001"
  "SENDMSG                       0002"
};

bool mic::get_builtin_number_by_name(const char *name, char *number) {

  using namespace mic;

  char bname[_MAX_MIC_BUILTIN_NAME + 1] = {0};
  copy_bytes_with_padding(bname, name, _MAX_MIC_BUILTIN_NAME, _WS);

  char *pos = strstr(builtin_name_number_map_, bname);
  if(pos == NULL)
    return false;

  pos += _MAX_MIC_BUILTIN_NAME;

  memcpy(number, pos, 4);

  return true;
}

void mic::phase_a0(const char *input, char *output, size_t len) {

  int i = 0, j = 0;
  char *cur = (char*)input;
  bool cmt = false;
  char *end_cmt = NULL;

  memset(output, 0, len);

  for(i = 0; i < len && *(cur + 1) != 0; i++, cur++) {

    if(cmt) {

      // find end-comment sequence '*/'
      if(strncmp(cur, _END_OF_COMMENT, 2) == 0) {

        cmt = !cmt;
        cur += 1;
      }

      continue;

    } else {

      if(strncmp(cur, _BEGIN_OF_COMMENT, 2) == 0) {

        cmt = !cmt;
        cur += 1;
        continue;
      }

      // control characters
      if(strchr(_CONTROL_CHARS, *cur) != NULL)
        output[j] += _WS;
      else
        output[j] += *cur;
      j++;
    }
  }

} // end of phase_a0()

size_t mic::phase_a1(mic::stmtlist_t& stmts, char* input) {

  using namespace std;

  char *tok;
  const char *delimiter = _STMT_DELIMITER;
  char *cur = strtok_r(input, delimiter, &tok);
  string text;
  while(cur != NULL) {

    if(strspn(cur, _WSS) == strlen(cur)) { // in case of empty statement

      cur = strtok_r(NULL, delimiter, &tok);
      continue;
    }

    text = cur;
    text += _STMT_DELIMITER;
    stmts.push_back(stmt_t("", text));

    cur = strtok_r(NULL, delimiter, &tok);
  }

  return stmts.size();

} // end of phase_a1()

bool mic::is_include(const std::string& s, std::string& inc_path)
  throw(mic::compiler_ex_t, mic::internal_ex_t)
{

  using namespace std;
  using namespace mic;

  string ex_info;
  char c = _SLASH;
  char *text = strdup(s.c_str());

  // leading '/'
  size_t pos = strspn(text, _WSS);
  if(text[pos] != _SLASH)
    return false;

  // keyword include
  // tokenize by: '/', ' ', '"'
  char *tok;
  char inc_delimiters[] =
# ifdef __OS400__
    "\x61\x40\x7F";
# else
    "/ \"";
# endif
  char *str = strtok_r(text, inc_delimiters, &tok);
  if(strcmp(str, _KEYWORD_INCLUDE) != 0)
    return false;

  // determine path name of the source unit to include
  int offset = str - text;
  text = strdup(s.c_str());
  text += offset + strlen(_KEYWORD_INCLUDE);

  regex_t reg;
  regex_t reg2;
  char *pattern =
# ifdef __OS400__
    "\x7F\x4B\x5C\x7F";
# else
    "\".*\"";
# endif
  char *pattern2 =
# ifdef __OS400__
    "\xBA\xB0\x40\xBB\x5C\xBA\xB0\x5E\x40\xBB";
# else
    "[^ ]*[^; ]";
# endif
  int r = regcomp(&reg, pattern, 0);
  if(r != 0) {

    ex_info = "regcomp() failed, pattern -- ";
    ex_info += pattern;
    throw internal_ex_t(ex_info);
  }

  r = regcomp(&reg2, pattern2, 0);
  if(r != 0) {

    ex_info = "regcomp() failed, pattern -- ";
    ex_info += pattern2;
    throw internal_ex_t(ex_info);
  }

  regmatch_t m;
  r = regexec(&reg, text, 1, &m, 0);
  regfree(&reg);

  if(r == 0) {
    inc_path = string((text + m.rm_so + 1), m.rm_eo - m.rm_so - 2); // erase \"
  } else {

    // try pattern2
    r = regexec(&reg2, text, 1, &m, 0);
    regfree(&reg2);
    if(r != 0) {

      ex_info = "invalid include directive -- ";
      ex_info += s;
      throw compiler_ex_t(ex_info);
    }

    inc_path = string((text + m.rm_so), m.rm_eo - m.rm_so);
  }

  return true;

} // end of is_include()

bool mic::phase_a2(
                   mic::stmtlist_t& stmts,
                   const mic::stringlist_t& inc_dirs,
                   int& depth
                   )
  throw(mic::compiler_ex_t)
{

  using namespace std;
  using namespace mic;

  bool has_include = false;
  string stmt;
  string inc_path;
  string ex_info;

  stmtlist_t::iterator it = stmts.begin();
  stmtlist_t::iterator it_tmp;
  while(it != stmts.end()) {

    stmt = it->text();
    if(is_include(stmt, inc_path)) {

      // load included source unit
      string source = read_source_file(inc_path, inc_dirs);

      // do phase_a0() on included source unit
      const char *in = source.c_str();
      size_t len = strlen(in);
      char *out = (char*)malloc(len);

      phase_a0(in, out, len);

      // do phase_a1() on included source unit
      stmtlist_t l;
      phase_a1(l, out);
      free(out);

      // insert statements of included source unit into stmts
      string inc_title("/* ");
      inc_title += inc_path + " */";
      stmts.insert(it, stmt_t(inc_title, ""));
      stmts.insert(it, l.begin(), l.end());

      has_include = true;

      // erase include statement
      it_tmp = it;
      ++it_tmp;

      stmts.erase(it);
      it = it_tmp;

      if(it_tmp == l.end())
        break;
      else
        continue;
    } // end of if(is_include())

    ++it;
  }

  return has_include;
}

void mic::phase_a3(mic::stmtlist_t& l) {

  using namespace std;

  mic::stmtlist_t::iterator it = l.begin();
  for(; it != l.end(); ++it) {

    string& text = it->text_;
    char q_c = 0;
    bool quote = false;
    string::iterator istr = text.begin();
    for(; istr != text.end(); ++istr) {

      char& ch = *istr;

      if(quote) {

        if(ch == q_c)
          quote = false;

        continue;
      } else {

        if(ch == '\'') {

          q_c = ch;
          quote = true;
          continue;
        }

        if(ch == '"') {

          q_c = ch;
          quote = true;
          continue;
        }

        ch = toupper(ch);
      }

    }

  } // end of for(it)

} // end of phase_a3()

std::string
mic::read_source_file(
                      const std::string& path,
                      const mic::stringlist_t& inc_dirs
                      )
  throw(mic::compiler_ex_t)
{

  using namespace std;
  using namespace mic;

  string ex_info;
  bool absolute = false;

  // check path_
  size_t len = path.length();
  if(len < 1) // empty path name
    throw compiler_ex_t("empty source file path name");

  if(path.at(0) == _SLASH) {

    absolute == true;
    if(len < 2) // empty absolute path name
      throw compiler_ex_t("empty source file path name");
  }

  int job_ccsid = get_job_ccsid();

  // try path first
  bool opened = false;
  int fd = open(path.c_str(), O_RDONLY | O_TEXTDATA | O_CCSID, 0, job_ccsid);
  if(fd != -1)
    opened = true;
  else if(!absolute) { // relative path name

    // try directory names stored in inc_dirs
    string path;
    stringlist_t::const_iterator it = inc_dirs.begin();
    for(; it != inc_dirs.end(); ++it) {

      string dir(*it);
      len = dir.length();
      if(dir.at(len - 1) != _SLASH)
        dir += _SLASH;

      path = dir + path;

      fd = open(path.c_str(), O_RDONLY | O_TEXTDATA | O_CCSID, 0, job_ccsid);
      if(fd != -1) {

        opened = true;
        break;
      }
    }

    if(!opened) {

      ex_info = "failed to read source file -- ";
      ex_info += path;
      throw compiler_ex_t(ex_info);
    }
  }

  // read source unit
  string source;
  char ch = 0;
  while(read(fd, &ch, 1) > 0)
    source += ch;

  close(fd);

  return source;
}

void mic::phase_a(
                  const char* source,
                  mic::stmtlist_t& stmts,
                  mic::stringlist_t inc_dirs
                  ) {

  int len = strlen(source);
  char *out = (char*)malloc(len);

  phase_a0(source, out, len);
  phase_a1(stmts, out);
  free(out);

  bool has_include = true;
  int depth = 0;
  while( has_include && depth < MAX_INCLUDE_DEPTH )
    has_include =
      phase_a2(
               stmts,
               inc_dirs,
               depth
               );

  phase_a3(stmts);

}

void mic::load_builtins(mic::builtinmap_t& m) {

  using namespace mic;
  using namespace std;

  // 0000, %inc, just a DEMO
  /*
    user code:
      mult(s) vv, %inc(ind);

    mic:
      CPYNV @0000-#1, IND;
      CALLI @0000, *, .@0000;
      MULT(S) VV, @0000-#RTN;

    rep_stmts:
      CPYNV @0000-#1, :1;
      CALLI @0000, *, .@0000;

    body:
      DCL DD @0000-#RTN BIN(4) AUTO;
      DCL DD @0000-#1   BIN(4) AUTO;
      DCL INSPTR .@0000 AUTO;
      ENTRY @0000 INT;
        ADDN(S) @0000-#1, 1;
        CPYNV   @0000-#RTN, @0000-#1;
        B .@0000;
   */

  // inc
  builtin_t inc("INC", "0000", 1, true);
  inc.rep_stmts_.push_back(stmt_t("", "CPYNV @0000-#1, :1;"));
  inc.rep_stmts_.push_back(stmt_t("", "CALLI @0000, *, .@0000;"));

  inc.body_.push_back(stmt_t("/* builtin INC */", "DCL DD @0000-#RTN BIN(4) AUTO;"));
  inc.body_.push_back(stmt_t("", "DCL DD @0000-#1   BIN(4) AUTO;"));
  inc.body_.push_back(stmt_t("", "DCL INSPTR .@0000 AUTO;"));
  inc.body_.push_back(stmt_t("", "ENTRY @0000 INT;"));
  inc.body_.push_back(stmt_t("", "ADDN(S) @0000-#1, 1;"));
  inc.body_.push_back(stmt_t("", "CPYNV   @0000-#RTN, @0000-#1;"));
  inc.body_.push_back(stmt_t("", "B .@0000;"));

  // memcpy
  builtin_t MEMCPY("MEMCPY", "0001", 3);

  MEMCPY.rep_stmts_.push_back(stmt_t("", "SETSPPFP @0001-#1, :1  ;"));
  MEMCPY.rep_stmts_.push_back(stmt_t("", "SETSPPFP @0001-#2, :2  ;"));
  MEMCPY.rep_stmts_.push_back(stmt_t("", "CPYNV    @0001-#3, :3  ;"));
  MEMCPY.rep_stmts_.push_back(stmt_t("", "CALLI @0001, *, .@0001 ;"));

  MEMCPY.body_.push_back(stmt_t("/* builtin MEMCPY */", "  DCL SPCPTR @0001-#1 AUTO        ;"));
  MEMCPY.body_.push_back(stmt_t("", " DCL SPCPTR @0001-#2 AUTO        ;"));
  MEMCPY.body_.push_back(stmt_t("", " DCL DD @0001-#3 BIN(4) AUTO     ;"));
  MEMCPY.body_.push_back(stmt_t("", "  DCL INSPTR .@0001 AUTO         ;"));
  MEMCPY.body_.push_back(stmt_t("", "  ENTRY @0001 INT                 ;"));
  MEMCPY.body_.push_back(stmt_t("", "   DCL CON @0001-BYTES-PER-COPY BIN(4) INIT(32752) ;"));
  MEMCPY.body_.push_back(stmt_t("", "  DCL DD @0001-LENGTH BIN(4)                   ;"));
  MEMCPY.body_.push_back(stmt_t("", "  DCL DD @0001-CH-TARGET CHAR(1) BAS(@0001-#1) ;"));
  MEMCPY.body_.push_back(stmt_t("", "  DCL DD @0001-CH-SOURCE CHAR(1) BAS(@0001-#2) ;"));
  MEMCPY.body_.push_back(stmt_t("", "  DCL DTAPTR @0001-TARGET-PTR AUTO      ;"));
  MEMCPY.body_.push_back(stmt_t("", "  DCL DTAPTR @0001-SOURCE-PTR AUTO      ;"));
  MEMCPY.body_.push_back(stmt_t("", " DCL DD @0001-REMAINED BIN(4) AUTO     ;"));
  MEMCPY.body_.push_back(stmt_t("", "  DCL DD @0001-TO-COPY BIN(4) AUTO      ;"));
  MEMCPY.body_.push_back(stmt_t("", "           CPYNV @0001-LENGTH, @0001-#3              ;"));
  MEMCPY.body_.push_back(stmt_t("", "           CPYNV @0001-REMAINED, @0001-LENGTH  ;"));
  MEMCPY.body_.push_back(stmt_t("", "          CPYNV @0001-TO-COPY, @0001-BYTES-PER-COPY ;"));
  MEMCPY.body_.push_back(stmt_t("", " LOOP:         CMPNV(B) @0001-REMAINED, @0001-TO-COPY / HI(=+2) ;"));
  MEMCPY.body_.push_back(stmt_t("", "         CPYNV @0001-TO-COPY, @0001-REMAINED;"));
  MEMCPY.body_.push_back(stmt_t("", "  : BRK 'SETDP'                     ;"));
  MEMCPY.body_.push_back(stmt_t("", "                   SETDP @0001-TARGET-PTR, @0001-CH-TARGET ;"));
  MEMCPY.body_.push_back(stmt_t("", "          SETDP @0001-SOURCE-PTR, @0001-CH-SOURCE ;"));
  MEMCPY.body_.push_back(stmt_t("", "            DCL DD DTAPTR-ATTR CHAR(7) AUTO ;"));
  MEMCPY.body_.push_back(stmt_t("", "         DCL DD * CHAR(1) DEF(DTAPTR-ATTR) INIT(X'04') ;"));
  MEMCPY.body_.push_back(stmt_t("", "         DCL DD DTAPTR-ATTR-LENGTH BIN(2) DEF(DTAPTR-ATTR) POS(2) ;"));
  MEMCPY.body_.push_back(stmt_t("", "          CPYNV DTAPTR-ATTR-LENGTH, @0001-TO-COPY ;"));
  MEMCPY.body_.push_back(stmt_t("", " BRK 'SETDPAT'                   ;"));
  MEMCPY.body_.push_back(stmt_t("", "          SETDPAT @0001-TARGET-PTR, DTAPTR-ATTR ;"));
  MEMCPY.body_.push_back(stmt_t("", "          SETDPAT @0001-SOURCE-PTR, DTAPTR-ATTR ;"));
  MEMCPY.body_.push_back(stmt_t("", "                   CPYBLA @0001-TARGET-PTR, @0001-SOURCE-PTR ;"));
  MEMCPY.body_.push_back(stmt_t("", "                   SUBN(S) @0001-REMAINED, @0001-TO-COPY ;"));
  MEMCPY.body_.push_back(stmt_t("", "         CMPNV(B) @0001-REMAINED, 0 / NHI(END-LOOP) ;"));
  MEMCPY.body_.push_back(stmt_t("", "                   ADDSPP @0001-#1, @0001-#1, @0001-TO-COPY ;"));
  MEMCPY.body_.push_back(stmt_t("", "          ADDSPP @0001-#2, @0001-#2, @0001-TO-COPY ;"));
  MEMCPY.body_.push_back(stmt_t("", "           B LOOP                  ;"));
  MEMCPY.body_.push_back(stmt_t("", "  END-LOOP: BRK 'MEMCPY-RTN'                       ;"));
  MEMCPY.body_.push_back(stmt_t("", "          B .@0001                       ;"));

  // sendmsg: 0002
  builtin_t SENDMSG("SENDMSG", "0002", 2);

  SENDMSG.rep_stmts_.push_back(stmt_t("", "        SETSPP @0002-#1, :1   ;"));
  SENDMSG.rep_stmts_.push_back(stmt_t("", "        CPYNV @0002-#2, :2   ;"));
  SENDMSG.rep_stmts_.push_back(stmt_t("", "        CALLI @0002, *, .@0002  ;"));

  SENDMSG.body_.push_back(stmt_t("/* builtin SENDMSG */", "DCL SPCPTR @0002-#1 AUTO;"));
  SENDMSG.body_.push_back(stmt_t("", "DCL DD @0002-#2 BIN(4) AUTO;"));
  SENDMSG.body_.push_back(stmt_t("", "DCL INSPTR .@0002;"));
  SENDMSG.body_.push_back(stmt_t("", "ENTRY @0002 INT;"));
  SENDMSG.body_.push_back(stmt_t("", "BRK '@0002-INIT'  ;"));
  SENDMSG.body_.push_back(stmt_t("", "DCL DD @0002-EC CHAR(256) AUTO;"));
  SENDMSG.body_.push_back(stmt_t("", "DCL SPCPTR @0002-EC-PTR AUTO INIT(@0002-EC);"));
  SENDMSG.body_.push_back(stmt_t("", "DCL SPC * BAS(@0002-EC-PTR);"));
  SENDMSG.body_.push_back(stmt_t("", "        DCL DD @0002-EC-BYTES-IN BIN(4) DIR;"));
  SENDMSG.body_.push_back(stmt_t("", "        DCL DD @0002-EC-BYTES-OUT BIN(4) DIR;"));
  SENDMSG.body_.push_back(stmt_t("", "        DCL DD @0002-EC-EXID CHAR(7) DIR;"));
  SENDMSG.body_.push_back(stmt_t("", "        DCL DD * CHAR(1) DIR;"));
  SENDMSG.body_.push_back(stmt_t("", "        DCL DD @0002-EC-EXDATA CHAR(240) DIR;"));
  SENDMSG.body_.push_back(stmt_t("", "DCL DD @0002-SNDPM-MSGID CHAR(7) AUTO INIT(' ');"));
  SENDMSG.body_.push_back(stmt_t("", "DCL SPCPTR .@0002-SNDPM-MSGID AUTO INIT(@0002-SNDPM-MSGID);"));
  SENDMSG.body_.push_back(stmt_t("", "DCL DD @0002-SNDPM-MSGF CHAR(20) AUTO INIT(' ');"));
  SENDMSG.body_.push_back(stmt_t("", "DCL SPCPTR .@0002-SNDPM-MSGF AUTO INIT(@0002-SNDPM-MSGF);"));
  SENDMSG.body_.push_back(stmt_t("", "DCL SPCPTR .@0002-SNDPM-MSG AUTO;"));
  SENDMSG.body_.push_back(stmt_t("", "DCL DD @0002-SNDPM-MSGLEN BIN(4) AUTO;"));
  SENDMSG.body_.push_back(stmt_t("", "DCL SPCPTR .@0002-SNDPM-MSGLEN AUTO INIT(@0002-SNDPM-MSGLEN);"));
  SENDMSG.body_.push_back(stmt_t("", "DCL DD @0002-SNDPM-MSGTYPE CHAR(10) AUTO INIT('*INFO');"));
  SENDMSG.body_.push_back(stmt_t("", "DCL SPCPTR .@0002-SNDPM-MSGTYPE AUTO INIT(@0002-SNDPM-MSGTYPE);"));
  SENDMSG.body_.push_back(stmt_t("", "DCL DD @0002-SNDPM-CALLSTACK-ENTRY CHAR(10) AUTO INIT('*');"));
  SENDMSG.body_.push_back(stmt_t("", "DCL SPCPTR .@0002-SNDPM-CALLSTACK-ENTRY AUTO INIT(@0002-SNDPM-CALLSTACK-ENTRY);"));
  SENDMSG.body_.push_back(stmt_t("", "DCL DD @0002-SNDPM-CALLSTACK-COUNTER BIN(4) AUTO INIT(1);"));
  SENDMSG.body_.push_back(stmt_t("", "DCL SPCPTR .@0002-SNDPM-CALLSTACK-COUNTER AUTO INIT(@0002-SNDPM-CALLSTACK-COUNTER);"));
  SENDMSG.body_.push_back(stmt_t("", "DCL DD @0002-SNDPM-MSGKEY CHAR(4) AUTO INIT(' ');"));
  SENDMSG.body_.push_back(stmt_t("", "DCL SPCPTR .@0002-SNDPM-MSGKEY AUTO INIT(@0002-SNDPM-MSGKEY);"));
  SENDMSG.body_.push_back(stmt_t("", "DCL OL @0002-AL-SNDPM ("));
  SENDMSG.body_.push_back(stmt_t("", "        .@0002-SNDPM-MSGID,"));
  SENDMSG.body_.push_back(stmt_t("", "        .@0002-SNDPM-MSGF,"));
  SENDMSG.body_.push_back(stmt_t("", "        .@0002-SNDPM-MSG,"));
  SENDMSG.body_.push_back(stmt_t("", "        .@0002-SNDPM-MSGLEN,"));
  SENDMSG.body_.push_back(stmt_t("", "        .@0002-SNDPM-MSGTYPE,"));
  SENDMSG.body_.push_back(stmt_t("", "        .@0002-SNDPM-CALLSTACK-ENTRY,"));
  SENDMSG.body_.push_back(stmt_t("", "        .@0002-SNDPM-CALLSTACK-COUNTER,"));
  SENDMSG.body_.push_back(stmt_t("", "        .@0002-SNDPM-MSGKEY,"));
  SENDMSG.body_.push_back(stmt_t("", "        @0002-EC-PTR"));
  SENDMSG.body_.push_back(stmt_t("", ") ARG;"));
  SENDMSG.body_.push_back(stmt_t("", "DCL SYSPTR .@0002-QMHSNDPM AUTO INIT('QMHSNDPM', TYPE(PGM));"));
  SENDMSG.body_.push_back(stmt_t("", "BRK '@0002-START'  ;"));
  SENDMSG.body_.push_back(stmt_t("", "        CPYNV @0002-EC-BYTES-IN, 256;"));
  SENDMSG.body_.push_back(stmt_t("", "        SETSPPFP .@0002-SNDPM-MSG, @0002-#1;"));
  SENDMSG.body_.push_back(stmt_t("", "        SETSPP .@0002-SNDPM-MSGLEN, @0002-#2;"));
  SENDMSG.body_.push_back(stmt_t("", "        CALLX .@0002-QMHSNDPM, @0002-AL-SNDPM, *;"));
  SENDMSG.body_.push_back(stmt_t("", "BRK '@0002-END'                 ;"));
  SENDMSG.body_.push_back(stmt_t("", "        B .@0002;"));

  m.insert(builtinmap_t::value_type("INC", inc));
  m.insert(builtinmap_t::value_type("MEMCPY", MEMCPY));
  m.insert(builtinmap_t::value_type("SENDMSG", SENDMSG));

}

void mic::phase_b(
                  mic::stmtlist_t& stmts,
                  mic::builtinmap_t& b_map
                  )
  throw(mic::compiler_ex_t, mic::internal_ex_t)
{

  using namespace mic;
  using namespace std;

  string b_name;
  stringlist_t b_used;
  string ex_info;
  stmtlist_t::iterator it_pend = stmts.end();
  regex_t reg;

  if(regcomp(&reg, "PEND[ ]*;", 0) != 0)
    throw internal_ex_t("regcomp() failed in mic's phase b");

  stmtlist_t::iterator it = stmts.begin();
  builtinmap_t::iterator b_it;
  for(; it != stmts.end(); ++it) {

    stmt_t& s = *it;

    // pend?
    if(s.is_pend(&reg)) {

      it_pend = it;
      break;
    }

    // call builtin?
    if(s.call_builtin(b_name)) {

      b_it = b_map.find(b_name);
      if(b_it == b_map.end()) {

        ex_info = "undefined builtin name -- ";
        ex_info += b_name;
        regfree(&reg);
        throw compiler_ex_t(ex_info);
      }

      builtin_t &b = b_it->second;
      b.replace(stmts, it, b_used);
    }
  }

  if(it_pend == stmts.end()) {

    ex_info = "PEND instruction missed";
    ex_info += b_name;
    regfree(&reg);
    throw compiler_ex_t(ex_info);
  }

  stringlist_t::iterator s_it = b_used.begin();
  for(; s_it != b_used.end(); ++s_it) {

    b_it = b_map.find(*s_it);
    if(b_it == b_map.end())
      ; // throw exception, un-defined builtin name; but it seems IMPOSSIBLE

    builtin_t &b = b_it->second;
    stmts.insert(it_pend, b.body().begin(), b.body().end());
  }

  regfree(&reg);

}

void mic::dump_stmts(
                     const mic::stmtlist_t& stmts,
                     std::string& output
                     ) {

  using namespace std;
  using namespace mic;

  output.clear();

  stmtlist_t::const_iterator it = stmts.begin();
  for(; it != stmts.end(); ++it)
    output += it->comment() + it->text();

}

void mic::phase_c(
                  mic::stmtlist_t& stmts,
                  mic_cmd_param_t& mic_parm
                  )
  throw(mic::internal_ex_t)
{

  using namespace std;
  using namespace mic;

  string src_stream;
  dump_stmts(stmts, src_stream);

  Qus_EC_t *ec = (Qus_EC_t *)malloc(_MIC_ECLEN);
  memset(ec, 0, _MIC_ECLEN);
  ec->Bytes_Provided = _MIC_ECLEN;

  char srcpf[] = {"QADBXRDBD QSYS      "};
  char srcmbr[] = {"GENUINE_LS"};
  char modtime[] = {"1000101000000"};

  QPRCRTPG(
           (char*)src_stream.c_str(),
           src_stream.length(),
           mic_parm.pgm_,
           mic_parm.text_,
           srcpf,
           srcmbr,
           modtime,         // sorry, the source never changes :p
           mic_parm.output_,
           1,
           mic_parm.public_auth_,
           mic_parm.options_.opts_,
           mic_parm.options_.num_,
           ec
           );
  if(ec->Bytes_Available != 0) {

    string ex_info = retrieve_exception_description(ec);
    string msgid(ec->Exception_Id, 7);
    free(ec);
    throw internal_ex_t(ex_info, msgid);
  }


  free(ec);

}

# ifdef __OS400__
void print_splf(Qus_SPLF0300_t* splfinfo) {

  using namespace mic;

  char cmd[256] = {0};
  int r = 0;
  char job_num[6 + 1] = {0};
  char job_user[10 + 1] = {0};
  char job_name[10 + 1] = {0};
  _RFILE *fp = NULL;
  _RIOFB_T *fb = NULL;
  char buf[_MIC_LIST_FILE_RLEN] = {0};

  // crtpf
  sprintf(cmd,
          "CRTPF FILE("_MIC_LIST_FILE") RCDLEN(132) "
          "FILETYPE(*DATA) IGCDTA(*YES)"
          );
  system(cmd);

  memcpy(job_num,  splfinfo->Job_Number, 6);
  trimr(job_num);
  memcpy(job_user, splfinfo->User_Name, 10);
  trimr(job_user);
  memcpy(job_name, splfinfo->Job_Name, 10);
  trimr(job_name);
  // cpysplf
  sprintf(cmd,
          "CPYSPLF FILE(%10.10s) TOFILE(%s) "
          "JOB(%s/%s/%s) SPLNBR(%d)",
          splfinfo->Spooled_File_Name,
          _MIC_LIST_FILE,
          job_num,
          job_user,
          job_name,
          splfinfo->Spooled_File_Nbr
          );
  if(system(cmd) != 0) {

    report_exception(exbase_t::unknown, "CPYSPLF failed", true);
    return;
  }

  // print _MIC_LIST_FILE
  fp = _Ropen(_MIC_LIST_FILE, "rr, rtncod=y");
  if(fp == NULL) {

    report_exception(exbase_t::unknown,
                     "failed to open "_MIC_LIST_FILE, true);
    return;
  }

  fb = _Rreadf(fp, buf, fp->buf_length, __DFT);
  while(fb->num_bytes == fp->buf_length) {

    printf("%132.132s"_NLS, buf);
    fb = _Rreadn(fp, buf, fp->buf_length, __DFT);
  }

  _Rclose(fp);

  // dltspf
  sprintf(cmd,
          "DLTSPLF FILE(%10.10s) "
          "JOB(%s/%s/%s) SPLNBR(%d)",
          splfinfo->Spooled_File_Name,
          job_num,
          job_user,
          job_name,
          splfinfo->Spooled_File_Nbr
          );
  system(cmd);

}

void mic::print_listinfo(const char *start_from, const char* prtf) {

  bool i = false;
  Qus_EC_t *ec = NULL;
  int copy = 0;
  char *ptr = NULL;
  int *listdata_offset = NULL; // 0x7C
  int *num_listentry = NULL;   // 0x84
  int *listentry_size = NULL;  // 0x88
  Qus_SPLF0300_t *splfinfo = NULL;

  ec = (Qus_EC_t*)malloc(_MIC_ECLEN);
  memset(ec, 0, _MIC_ECLEN);
  ec->Bytes_Provided = _MIC_ECLEN;

  QUSCRTUS(
           _MIC_LIST_SPC,
           "USRSPC    ",
           _MIC_LIST_SPC_SIZE,
           "\x00",
           "*EXCLUDE  ",
           "                                                  ",
           "*YES      ",
           ec
           );
  if(ec->Bytes_Available != 0) {

    report_exception(exbase_t::unknown,
                     "failed to creat space "_MIC_LIST_SPC,
                     true);
    return;
  }

  QUSLSPL(
          _MIC_LIST_SPC,
          "SPLF0300",
          "*ALL      ", // user name
          "*ALL                ", // 26a, job id
          "*STD      ", // type: *STD
          "          ", // User-specified data, do NOT use '*ALL'!
          ec,
          "                          ", // op grp 2
          NULL,
          0,
          0,  // ASP number, op grp 3
          "*CURRENT", // system name, op grp 4
          start_from, // start_date, time before phase C
          start_from + 7, // start_time
          "*LAST  ",
          "      "
          );
  if(ec->Bytes_Available != 0) {

    free(ec);
    report_exception(exbase_t::unknown,
                     "failed to list splf",
                     true);
    return;
  }

  QUSPTRUS(
           _MIC_LIST_SPC,
           &ptr,
           ec
           );

  listdata_offset = (int*)(ptr + 0x7C);
  num_listentry = (int*)(ptr + 0x84);
  listentry_size = (int*)(ptr + 0x88);

  splfinfo = (Qus_SPLF0300_t*)(
                               ptr
                               + *listdata_offset
                               + (*num_listentry - 1) * sizeof(Qus_SPLF0300_t)
                               );
  // @todo in csse that the real spooled file name is not
  // the same with mic_cmd_param_t::output_
  Qus_SPLF0300_t *last_splfinfo = splfinfo;
  for(i = 0; i < *num_listentry; i++, splfinfo--) {

    if(memcmp(splfinfo->Spooled_File_Name, prtf, 10) == 0) {

      copy = true;
      break;
    }
  }

  if(copy)
    print_splf(splfinfo);
  else if(*num_listentry > 0) // use the last spooled file
    print_splf(last_splfinfo);

  free(ec);
}

# else
void mic::print_listinfo(const char *start_from, const char* prtf) {

  printf("call print_listinfo() ... "_NLS);
}
# endif // if defined __OS400__

std::string mic::retrieve_exception_description(void* api_error_code) {

  using namespace std;

  Qus_EC_t *ec = (Qus_EC_t*)api_error_code;
  char *ex_data = (char*)ec + 16;
  Qmh_Rtvm_RTVM0100_t *info = NULL;
  string r;
  char ecbuf[_MIC_ECLEN] = {0};
  Qus_EC_t *this_ec = (Qus_EC_t*)ecbuf;
  string original_exid(ec->Exception_Id, 7);

  static const int INFO_LEN = 4096;
  info = (Qmh_Rtvm_RTVM0100_t*)malloc(INFO_LEN);
  memset(info, 0, INFO_LEN);
  info->Bytes_Available = INFO_LEN;
  this_ec->Bytes_Provided = _MIC_ECLEN;

  QMHRTVM(
          info,
          INFO_LEN,
          "RTVM0100",
          ec->Exception_Id,
          "QCPFMSG   QSYS      ",    // only for CPF and MCH messages
          ex_data,
          ec->Bytes_Available - 16,  // minus the header length of Qus_EC_t (16 bytes)
          "*YES      ",
          "*NO       ",
          this_ec
          );
  if(this_ec->Bytes_Available != 0) {

    free(info);
    r = "QMHRTVM() failed with excecption ID "
      + string(this_ec->Exception_Id, 7)
      + ", previous exception ID is "
      + original_exid
      + _NLS;
    return r;
  }

  char *info_ptr = (char*)info + 24;
  r = string(info_ptr, info->Length_Message_Returned)
    + _NLS
    + string(info_ptr + info->Length_Message_Returned, info->Length_Help_Returned)
    + _NLS;
 end:
  free(info);
  return r;
}

void mic::report_exception(
                           exbase_t::mic_ex_type_t type,
                           const std::string& info,
                           bool from_shell
                           ) {

  using namespace std;

  static const char* ex_type_names[] = {
    "unknown error",
    "", // information
    "compiler error",
    "internal error"
  };

  string str("mic: ");
  str += ex_type_names[type];
  str += " -- " + info;
  if(from_shell) {

    if(type == exbase_t::information)
      cout << str << endl;
    else
      cerr << str << endl;

    return;
  }

  // QMHSNDPM
  Qus_EC_t *ec = NULL;
  char msgkey[4] = {0};

  ec = (Qus_EC_t*)malloc(_MIC_ECLEN);
  memset(ec, 0, _MIC_ECLEN);
  ec->Bytes_Provided = _MIC_ECLEN;

  QMHSNDPM(
           "CPF9898",
           "QCPFMSG   QSYS      ",
           (char*)str.c_str(),
           str.size(),
           "*INFO     ",
           "*PGMBDY   ",
           1,
           msgkey,
           ec
           );

  free(ec);
}

int mic::get_job_ccsid() {

  Qwc_JOBI0400_t jobi;
  jobi.Bytes_Avail = sizeof(Qwc_JOBI0400_t);
  QUSRJOBI(
           &jobi,
           jobi.Bytes_Avail,
           "JOBI0400",
           "*                         ",
           "                "
           );

  return jobi.Coded_Char_Set_ID;
}

# ifdef __OS400__
void mic::get_cur_lib(char *curlib) {

  memset(curlib, _WS, 10);

  static const size_t L = 1024;
  Qwc_JOBI0700_t *info = (Qwc_JOBI0700_t*)malloc(L);
  memset(info, 0, L);
  info->Bytes_Avail = L;

  QUSRJOBI(
           info,
           L,
           "JOBI0700",
           "*                         ",
           "                "
           );
  size_t offset = 80 + 11 * (info->Libs_In_Syslibl + info->Prod_Libs);
  memcpy(curlib, (char*)info + offset, 10);

  free(info);

}
# else
void mic::get_cur_lib(char *curlib) {}
# endif

/* eof - mic.cpp */
