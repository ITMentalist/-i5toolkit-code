/**
 * This file is part of i5/OS Programmer's Toolkit.
 * 
 * Copyright (C) 2010, 2011  Junlei Li (李君磊).
 * 
 * i5/OS Programmer's Toolkit is free software: you can redistribute
 * it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * i5/OS Programmer's Toolkit is distributed in the hope that it will
 * be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with i5/OS Programmer's Toolkit.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

/**
 * @file inst-tmpl.h
 *
 * Declarations of instruction templates used by MIPORTAL are placed in this file.
 */

# ifndef __miportal_inst_tmpl_h__
# define __miportal_inst_tmpl_h__

/**
 * Creation template of CRTS. (96 bytes)
 */
typedef _Packed struct tag_crts {
  int bytes_in;
  int bytes_out;
  // object ID
  char obj_type[2];
  char obj_name[30];
  // creation options
  char crt_opt[4];
  // recovery options
  char filler1[2];
  unsigned short asp_num;
  // space-size, initial value
  int spc_size;
  char init_val[1];
  // performance class
  char perf_cls[4];
  char filler2[1];
  // public auth
  char pub_auth[2];
  // template extension offset
  int ext_tmpl_off;
  // context
  void *ctx;
  // acess group
  void *ag;
} crts_t;

/**
 * Template extension of CRTS. (64 bytes)
 */
typedef _Packed struct tag_crts_ext {
  void *owner;  // SYP to the created space object's owner USRPRF
  int largest_size_needed;
  char domain[2];
  char filler[42];
} crts_ext_t;

/**
 * Creation template of CRTINX (176 bytes)
 */
typedef _Packed struct tag_crtinx {
  int bytes_in;
  int bytes_out;
  // object ID
  char obj_type[2];
  char obj_name[30];
  char crt_opt[4];         // creation options
  // recovery options
  char filler1[2];
  unsigned short asp_num;
  int spc_size;            // space-size, initial value
  char init_val[1];        // initial value of space
  char perf_cls[4];        // performance class
  char filler2[3];
  int ext_tmpl_off;        // template extension offset
  void *ctx;               // context
  void *ag;                // acess group
  char attr[1];            // index attributes
  unsigned short arg_len;  // argument length
  unsigned short key_len;  // key length
  // the following are fields belong to the longer creation template
  char filler3[12];
  char tmpl_ver[1]; // template version, must be hex 00
  char inx_fmt[1];  // index format. hex 00=max object size of 4GB, hex 01=max object size of 1TB
  char filler4[61];
} crtinx_t;

/**
 * Option list of index managment instructions
 */
typedef _Packed struct tag_inx_oplist {
  char rule[2];
  unsigned short arg_len;  // argument length
  short arg_off;           // argument offset
  short occ_cnt;           // occurance count
  short rtn_cnt;           // returned count
  /* entries */
  unsigned short ent_len;
  short ent_off;
} inx_oplist_t;

/**
 * Instruction template for GENUUID
 */
typedef _Packed struct tag_genuuid {
  unsigned bytes_in;
  unsigned bytes_out;
  char filler1[8];
  char uuid[16];
} genuuid_t;

# endif // !defined __miportal_inst_tmpl_h__
