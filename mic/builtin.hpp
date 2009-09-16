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
 * @file builtin.hpp
 *
 * describes a mic builtin
 */

# ifndef __builtin_hpp__
# define __builtin_hpp__

namespace mic {

  struct builtin_t;

  /// map of builtin_t
  typedef std::map<std::string, builtin_t> builtinmap_t;

};

/**
 * mic builtin
 */
struct mic::builtin_t {

  friend void load_builtins(builtinmap_t&);

  /// ctor
  builtin_t(
            const std::string& name,
            const std::string& bnum,
            unsigned short num_parms = 0,
            bool return_val = false
            ) {

    name_ = name;
    bnum_ = bnum;
    num_parms_ = num_parms;
    return_val_ = return_val;
  }

  /**
     replace user code with CALLIs
      - parse user's builin invocation: e.g. %memcpy(str, "huhu", 4);
      - 用regexp, strtok_r取出参数和参数个数，个数不对throw exception
      - 对rep_stmts_中各 stmt 做参数替换, :1, :2, ....
      - remove掉 stmt 中 user code，insert 替换后的 stmt 集合
        - 对于builtin return value被用作operand的 stmt，不remove,
          在 stmt 中替换 builtin 调用为 builtin return value
      - body呢? 应该在参数中加个 builtin_section，指最终出现在
        source stream里的整个 builtin section, 含所有builtins，
        那么，一个builtin是否已经在这里出现过如何标识?

     procedure
     @code
     stmt_t& stmt = *it;
     // parse 出 builtin invocation 字串
     // regex: '%.*(.*)'
     string b_inv_str(stmt.text().c_str() + start, length);

     // 是否用作instruction operand，看
     bool as_operand = false;

     // parse 出builtin调用参数列表 op_list
     // 如果参数个数不符，throw exception

     // 遍历 rep_stmts_，COPY构造新stmt_t rr ，用 op_list 中各参数替换 rr 中 :1, :2, ... :n
     // 之后，将替换后的 rr 插入 stmts (by it)

     // 替换 b_inv_str
     string text = stmt.text();
     if(as_operand)
       text.replace(start, length, @nnnn-#RTN); // builtin_t::rtn_val_name()
     else
       text.replace();
     stmt.text(text);

     // 处理 b_used，找(by name)，没有则 push_back

     @endcode

   */
  void replace(
               stmtlist_t& stmts,
               stmtlist_t::iterator it,
               stringlist_t& b_used
               ) {

    using namespace mic;
    using namespace std;

    int r = 0;
    string ex_info;
    stmt_t& stmt = *it;
    const char *stmt_text = stmt.text().c_str();
    int b_inv_str_start = 0, b_inv_str_length = 0;

    // pase builtin invocation string
    regex_t reg;
    const char *pattern =
# ifdef __OS400__
      "\x6C\x4B\x5C\x4D\x4B\x5C\x5D"
# else
      "%.*(.*)"
# endif
      ;
    r = regcomp(&reg, pattern, 0);
    if(r != 0) {

      // throw exception
      return;
    }

    regmatch_t m;
    r = regexec(&reg, stmt_text, 1, &m, 0);
    regfree(&reg);
    if(r != 0) {

      // throw exception
      return;
    }

    b_inv_str_start = m.rm_so;
    b_inv_str_length = m.rm_eo - m.rm_so;
    string b_inv_str(stmt_text + b_inv_str_start, b_inv_str_length);

    // is builtin invocation string used as an instruction operand
    bool as_operand = false;
    string pre(stmt_text, b_inv_str_start);
    size_t pos = pre.find_first_of(_COLON);
    if(pos != string::npos) // there's a LABEL
      pre.erase(0, pos + 1);

    if(pre.find_first_not_of(_WS) == string::npos)
      as_operand = false; // pre is BLANK
    else
      as_operand = true;  // pre is NOT blank

    // parse parameter list passed by builtin's caller
    stringlist_t plist;
    char *inv = strdup(b_inv_str.c_str());
    inv[b_inv_str.find_first_of(_RIGHT_BRAKET)] = 0;
    inv += b_inv_str.find_first_of(_LEFT_BRAKET) + 1;
    char *tokptr;
    char *del = 
# ifdef __OS400__
      "\x6B\x40"
# else
      ", "
# endif
      ;
    char *tok = strtok_r(inv, del, &tokptr);
    while(tok != NULL) {

      plist.push_back(tok);
      tok = strtok_r(NULL, del, &tokptr);
    }

    // check number of parameters
    if(plist.size() != num_parms_) { // invalid parameter number

      ex_info = "invalid number of parameters when invoking builtin %";
      ex_info += name_;
      throw compiler_ex_t(ex_info);
    }

    // replace statements in rep_stmts_
    stmtlist_t::iterator it_rep = rep_stmts_.begin();
    for(; it_rep != rep_stmts_.end(); ++it_rep) {

      stmt_t rstmt(*it_rep);
      string rtext = rstmt.text();
      stringlist_t::iterator sit = plist.begin();
      int parm_index = 1;
      char parm_str[8] = {0};
      for(; sit != plist.end(); ++sit, parm_index++) {

        sprintf(parm_str,
# ifdef __OS400__
                "\x7A\x6C\x84"
# else
                ":%d"
# endif
                , parm_index
                ); // here
        replace_all(rtext, parm_str, sit->c_str());
      }

      rstmt.text(rtext);
      stmts.insert(it, rstmt);

    } // end of for it_rep

    // replace builtin invocation string
    string b_text(stmt_text);
    string b_inv_rep;
    if(as_operand)
      b_inv_rep = return_value_name();
    b_text.replace(b_inv_str_start, b_inv_str_length, b_inv_rep);
    it->text(b_text);

    // handle b_used
    bool registerd = false;
    stringlist_t::iterator sit = b_used.begin();
    for(; sit != b_used.end(); ++sit) {

      if(name_.compare(*sit) == 0) {

        registerd = true;
        break;
      }
    }

    if(!registerd)
      b_used.push_back(name_);

  } // end of replace()

  /**
   * returns the name of a builtin's return value
   */
  std::string return_value_name() {

# ifdef __OS400__
    std::string r("\x7C");
    r += bnum_ + "\x60\x7B\xD9\xE3\xD5";
# else
    std::string r("@");
    r += bnum_ + "-#RTN";
# endif

    return r;
  }

  /// returns builtin body
  const stmtlist_t& body() { return body_; }

protected:

  /// builtin name
  std::string name_;

  /// builtin number
  std::string bnum_;

  /// 用于替换的 stmt 集合
  stmtlist_t rep_stmts_;

  /// builtin body
  stmtlist_t body_;

  /// number of builtin parameters
  unsigned short num_parms_;

  /// whether or not returns a value
  bool return_val_;

};

# endif // !defined __builtin_hpp__
/* eof - builtin.hpp */
