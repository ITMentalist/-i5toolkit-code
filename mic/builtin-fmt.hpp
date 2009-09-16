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
 * @file builtin-fmt.hpp
 *
@section sect_builtin_index_format
key format: type code, char(1); builtin number, char(4), stmt-number ubin(2)
 - index header
   00 00000000 0000
   -- -------- ----
   1b 4bytes   2b
 - builtin header
   01 000000F1 0000
   -- -------- ----
   1b 4bytes   2b
 - stmt replacement
   02 000000F1 0001
   -- -------- ----
   1b 4bytes   2b
 - stmt body
   03 000000F1 0001
   -- -------- ----
   1b 4bytes   2b

 here-today: 检查下面结构，即fill-inx.cpp

 */

# ifndef __builtin_fmt_hpp__
# define __builtin_fmt_hpp__

/// 5
#   define _MIC_BUILTIN_KEY 7

/// max length a mic builtin name
#   define _MAX_MIC_BUILTIN_NAME 30

/// mic builtin index entry length
#   define _MIC_BUILTIN_INX_LEN 256

#   define _INDEX_ENTRY_TYPE_HEADER  '\x00'
#   define _INDEX_ENTRY_TYPE_BUILTIN '\x01'
#   define _INDEX_ENTRY_TYPE_STMT    '\x02'

typedef
#   ifdef __OS400__
_Packed
#   endif
struct tag_builtin_key {

  char type_[1];
  char builtin_num_[4];
  unsigned short stmt_num_;

} builtin_key_t;

typedef 
#   ifdef __OS400__
_Packed
#   endif
struct tag_builtin_index {

  /**
   * builtin_index_t only use the type_ field of the 5 bytes key
   *
   * type code of index header is hex 00
   */
  builtin_key_t key_;

  unsigned short index_ver_;
  unsigned short min_mic_ver_;
  unsigned short max_mic_ver_;
  unsigned short num_builtins_;
  char release_notes_[_MIC_BUILTIN_INX_LEN - 8 - _MIC_BUILTIN_KEY];

} builtin_index_t;

typedef
#   ifdef __OS400__
_Packed
#   endif
struct tag_builtin_header {

  /**
   * builtin_header_t
      - set key_.type_ to hex 01
      - use key_.builtin_num_ as builtin number
      - use key_.stmt_num_ as the number of statements

      @remark each builtin's stmt number starts from hex 0001
   */
  builtin_key_t key_;

  /// builtin name
  char builtin_name_[_MAX_MIC_BUILTIN_NAME];

  /// number of params
  unsigned short num_params_;

  /// user data, e.g. comments
  char user_data_[_MIC_BUILTIN_INX_LEN - _MIC_BUILTIN_KEY - _MAX_MIC_BUILTIN_NAME - 2];

} builtin_header_t;

typedef
#   ifdef __OS400__
_Packed
#   endif
struct tag_builtin_stmt {

  builtin_key_t key_;

  char stmt_[_MIC_BUILTIN_INX_LEN - _MIC_BUILTIN_KEY];

} builtin_stmt_t;

#   define _EMI_BUILTIN_INDEX "EMIBUILTINLSBIN     "

# endif
