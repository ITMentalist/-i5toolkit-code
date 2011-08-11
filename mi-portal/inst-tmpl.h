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

# endif // !defined __miportal_inst_tmpl_h__
