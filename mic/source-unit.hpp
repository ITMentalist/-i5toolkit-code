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
 * @file source_unit.hpp
 *
 * @todo MEMO: 新mic去掉 USESTMF 参数，没有用，因为在有了 /include 特性后
 * DBF和STMF可以相互include，这参数就根本没用了
 */

# ifndef __source_unit_hpp__
# define __source_unit_hpp__

namespace mic {

  struct source_unit;

};

/**
 * i represent a source unit
 */
struct mic::source_unit {

  /// ctor()
  source_unit() {
  }

  /**
   * ctor()
   *
   * @param[in] path, path of source file. path name could be either a database
   *            file member name of the path of a stream file. If path name refers
   *            to a stream file, it could be either a relative path name or a
   *            absolute path name.
   *            /qsys.lib
   * @param[in] inc_dirs, include directories
   *
   * @remark To determine a i5/OS job's current directory, one should
   *         use CL commands DSPCURDIR or RTVCURDIR. To modify a job's
   *         current directory, use CL commands CHGCURDIR or CHDIR
   */
  source_unit(
              const std::string& path,
              const mic::stringlist_t& inc_dirs
              ) {

    path_ = path;

    // try to locate and load target source file
    read_source_file(inc_dirs);
  }

  /// returns status of the currrent instance of class source_unit
  bool status() {

    return status_;
  }

  /// returns source path
  const std::string& path() {

    return path_;
  }

  /// returns source content
  const char* source() {

    return source_.c_str();
  }

  operator bool() {

    return status_;
  }

  /// destructor
  virtual ~source_unit() {
  }

protected:

  /**
     locate and read source file
    
     algorithm to locate source file
      - if path_ is an absolute path name, inc_dirs is ignored
      - if path_ is a relative path name, mic tries to open target source
        unit with name path_, then mic tests all directory names
        stored in inc_dirs.  The first available
        source unit with name path_ found in all directory names
        is adopted.
    
     @post source_
     @post status_
   */
  void read_source_file(const mic::stringlist_t& inc_dirs);

  std::string path_;

  std::string source_;

  bool status_;

};

# endif // __source_unit_hpp__
