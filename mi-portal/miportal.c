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
 * @file miportal.c
 *
 * @todo Type of the MI object to store pointers requested by clients
 * @todo call MIPORTAL for 256 times (看 auto-extend)
 * @todo 目前还没有设计回收 PTR-INX 的接口 (for clients)
 */

# include <stdlib.h>
# include <stdio.h>
# include <string.h>

# include "inst-tmpl.h"

/// @todo prototypes of MI instructions should be moved to other source unit
# pragma linkage (_SETSPPFP, builtin)
void* _SETSPPFP(void* /* source pointer */);

# pragma linkage (_CPYBWP, builtin)
void _CPYBWP(void*, void*, int);

# pragma linkage (_CRTS, builtin)
void _CRTS(void*, void*);

/**
 * Creates PTR-INX (index object to store pointers requested by clients
 * @post static SYP _ptr_inx
 */
void create_ptr_inx();
# define MIPORTAL_PTR_INX "miportal-ptr-index            "

/**
 * Format of 32-byte pointer-index entries
 */
typedef _Packed struct tag_ptr_inx_entry {
  char key[16];  // 16-byte UUID
  void *ptr;
} ptr_inx_entry_t;

typedef _Packed struct tag_ptr {
  void *ptr;
} ptr_t;

/**
 * Stores a pointer into PTR-INX or update an existing inx entry
 *
 * @param pptr, address of the pointer to store into PTR-INX
 * @return ptr-ID
 * @pre _ptr_inx
 */
int store_ptr(char *ptr_id, void **pptr);

/**
 * Remove a ptr-entry from PTR-INX
 */
int release_ptr(char *ptr_id, void** pptr);

/**
 * Locate a ptr by key
 */
int read_ptr(char *ptr_id, void **pptr);

void MATMATR (void*, void*, void*, void*);
void GENUUID (void*, void*, void*, void*);
void RSLVSP2 (void*, void*, void*, void*);
void ENQ (void*, void*, void*, void**);
void DEQWAIT (void*, void*, void*, void*);

/**
 * @param[in] op1, 16-byte pointer ID
 */
void RELEASE_PTR(void* op1, void*, void*, void*);

// space pointer operations
void SETSPPFP (void*, void*, void*, void*);

// 8. read_addr(spp, buf, len)
void READ_ADDR (void*, void*, void*, void*);
// 9. write_addr(spp, buf, len)
void WRITE_ADDR (void*, void*, void*, void*);
// 10. ADDSPP
void ADDSPP (void*, void*, void*, void*);
// 11. SUBSPP
void SUBSPP (void*, void*, void*, void*);
// 12. SUBSPPFO
void SUBSPPFO (void*, void*, void*, void*);
// 13. STSPPO
void STSPPO (void*, void*, void*, void*);
// 14. SETSPPO
void SETSPPO (void*, void*, void*, void*);
// 15. NEW_PTR
void NEW_PTR (void*, void*, void*, void*);
// 16. CMPPTRT
void CMPPTRT (void*, void*, void*, void*);

typedef void proc_t(void*, void*, void*, void*);
static proc_t* proc_arr[512] = {
  NULL,
  &MATMATR, &GENUUID, &RSLVSP2, &ENQ, &DEQWAIT, &RELEASE_PTR,
  &SETSPPFP, &READ_ADDR, &WRITE_ADDR, &ADDSPP, &SUBSPP, &SUBSPPFO, &STSPPO, &SETSPPO,
  &NEW_PTR, &CMPPTRT,
  NULL
};

/**
 * System pointer to pointer-space. This space object is created to
 * store pointers requested by clients of MIPORTAL.
 *
 * @remark To allowed _ptr_inx be used crossing calls to MIPORTAL,
 *         MIPORTAL should be compiled to use a persistend ACTGRP.
 */
static void *_ptr_inx = NULL;
static char _dbg[512] = {0};

int main(int argc, char *argv[]) {

  unsigned short inx = 0;

  if(argc < 2) /* at least, the instruction-index should be passed */
    return -1;

  inx = *(unsigned short*)argv[1];
  proc_arr[inx](argv[2], argv[3], argv[4], argv[5]);

  return 0;
}

/// index = 1. _MATMATR1
# pragma linkage (_MATMATR1, builtin)
void _MATMATR1(void*, void*);

void MATMATR (void *op1, void *op2, void *op3, void *op4) {
  _MATMATR1(op1, op2);
}

/// index = 2. _GENUUID
# pragma linkage (_GENUUID, builtin)
void _GENUUID(void*);

void GENUUID (void *op1, void *op2, void *op3, void *op4) {
  _GENUUID(op1);
}

/// index = 3. _RSLVSP2
# pragma linkage (_RSLVSP2, builtin)
void _RSLVSP2(void*, void*);

void RSLVSP2 (void *op1, void *op2, void *op3, void *op4) {
  void *syp = NULL; // system pointer to the MI obj to resolve

  _RSLVSP2(&syp, op2);

  // return the offset of SYP into PTR-INX as op1
  store_ptr(op1, &syp);
}

# pragma linkage(_CRTINX, builtin)
void _CRTINX(void* /* address of SYP to inx */,
             void* /* creation template */);

/**
 * Create an index object with the following attributes
 *  - temparory
 *  - with a fixed-length associated space of length 4K
 *  - fixed-length index entries
 *  - immediate update
 *  - insertion by key
 *  - entry format: both pointers and scalar data
 *  - optimized for random references
 *  - do not track index coherency
 *  - maximum object size of 1 Terabyte
 */
void create_ptr_inx() {

  crtinx_t tmpl;
  size_t len = sizeof(tmpl);

  memset(&tmpl, 0, len);
  tmpl.bytes_in = len;
  memcpy(tmpl.obj_type, "\x0E\x01", 2);
  memcpy(tmpl.obj_name, MIPORTAL_PTR_INX, 30);
  tmpl.spc_size = 0x1000;
  memcpy(tmpl.perf_cls, "\x91\x00\x00\x00", 4);
  tmpl.attr[0] = 0x71;
  tmpl.arg_len = 32;
  tmpl.key_len = 16;
  // longer template
  tmpl.inx_fmt[0] = 0x01;

  _CRTINX(&_ptr_inx, &tmpl);

  // for debug reason, log _ptr_inx to somewhere
  memcpy(_dbg, &_ptr_inx, 16);
}

# pragma linkage(_INSINXEN, builtin)
void _INSINXEN(void**, // address of SYP to target index object
               void*,  // arguemnt
               void*   // option list
               );

int store_ptr(char *ptr_id, void **pptr) {

  genuuid_t id;
  inx_oplist_t oplist;
  ptr_inx_entry_t ent;

  // make sure PTR-INX exists
  if(_ptr_inx == NULL)
    create_ptr_inx();

  // key portion of index entry, 16-byte UUID
  memset(&id, 0, sizeof(genuuid_t));
  id.bytes_in = sizeof(genuuid_t);
  _GENUUID(&id);
  memcpy(ptr_id, id.uuid, 16);

  memset(&oplist, 0, sizeof(inx_oplist_t));
  memcpy(ent.key, id.uuid, 16);
  ent.ptr = *pptr;
  memcpy(oplist.rule, "\x00\x02", 2);  // insert with replacement
  oplist.occ_cnt = 1;
  oplist.ent_len = sizeof(ptr_inx_entry_t);
  oplist.ent_off = 0;
  _INSINXEN(&_ptr_inx, &ent, &oplist);

  return 0;
}

# pragma linkage(_RMVINXEN1, builtin)
void _RMVINXEN1(void *,  // returned index entry
                void **, // address of SYP to target index object
                void *,  // option list
                void *   // search key
                );

int release_ptr(char *ptr_id, void** pptr)  {

  inx_oplist_t oplist;
  ptr_inx_entry_t ent;
  if(_ptr_inx == NULL)
    return -1;

  // remove inx entry by 16-byte ptr_id
  memset(&oplist, 0, sizeof(inx_oplist_t));
  memcpy(oplist.rule, "\x00\x01", 2);  // EQ
  oplist.occ_cnt = 1;
  oplist.arg_len = 16; // length of search-key
  _RMVINXEN1(&ent, &_ptr_inx, &oplist, ptr_id);

  // passed the pointer value stored in the removed entry back to ...
  *pptr = ent.ptr;

  // @todo check ent.rtn_cnt
  return 0;
}

# pragma linkage(_FNDINXEN, builtin)
void _FNDINXEN(void *,  // returned index entry
               void **, // address of SYP to target index object
               void *,  // option list
               void *   // search key
               );

int read_ptr(char *ptr_id, void **pptr)  {

  inx_oplist_t oplist;
  ptr_inx_entry_t ent;
  char search_key[16] = {0};
  if(_ptr_inx == NULL)
    return -1;

  // remove inx entry by 16-byte ptr_id
  memset(&oplist, 0, sizeof(inx_oplist_t));
  memcpy(oplist.rule, "\x00\x01", 2);  // EQ
  oplist.occ_cnt = 1;
  oplist.arg_len = 16; // length of search-key
  memcpy(search_key, ptr_id, 16);
  _FNDINXEN(&ent, &_ptr_inx, &oplist, search_key);

  // passed the pointer value stored in the removed entry back to ...
  *pptr = ent.ptr;

  // @todo check ent.rtn_cnt
  return 0;
}

/// index = 4. _ENQ
# pragma linkage (_ENQ, builtin)
void _ENQ(void*, void*, void*);

void ENQ (void *op1, void *op2, void *op3, void *op4) {

  void* syp;

  // locate SYP in PTR-INX
  read_ptr(op1, &syp);

  // enqueue
  _ENQ(&syp, op2, op3);
}

/// index = 5, _DEQWAIT
# pragma linkage (_DEQWAIT, builtin)
void _DEQWAIT(void *prefix, void *msg, void *q);

void DEQWAIT (void *op1, void *op2, void *op3, void *op4) {

  void* syp;

  // locate SYP in PTR-INX
  read_ptr(op3, &syp);

  // deq
  _DEQWAIT(op1, op2, &syp);
}

/// index = 6, RELEASE_PTR
void RELEASE_PTR (void *op1, void *op2, void *op3, void *op4) {

  void *ptr = NULL; // released MI pointer

  release_ptr(op1, &ptr);
}

/// index = 7, SETSPPFP
void SETSPPFP (void *op1, void *op2, void *op3, void *op4) {

  void *spp = NULL;
  void *src_ptr = NULL;

  read_ptr(op2, &src_ptr);
  spp = _SETSPPFP(src_ptr);
  store_ptr(op1, &spp);
}

/**
 * index = 8, read from an SLS address pointed to by a space pointer
 *
 * @param [in] op1, ID of the source space pointer
 * @param [out] op2, buffer provided by client
 * @param [in] op3, number of bytes to read
 */
void READ_ADDR (void *op1, void *op2, void *op3, void *op4) {

  void *spp = NULL;
  unsigned len = *(unsigned*)op3;

  read_ptr(op1, &spp);
  memcpy(op2, spp, len);
}

/**
 * index = 9, write to an SLS address pointed to by a space pointer
 *
 * @param [in] op1, ID of the target space pointer
 * @param [in] op2, buffer provided by client
 * @param [in] op3, number of bytes to write
 */
void WRITE_ADDR (void *op1, void *op2, void *op3, void *op4) {

  void *spp = NULL;
  unsigned len = *(unsigned*)op3;

  read_ptr(op1, &spp);
  memcpy(spp, op2, len);
}

/**
 * 10. ADDSPP
 *
 * @param [in] op1, target pointer
 * @param [in] op2, source pointer
 * @param [in] op3, bin(4) incremention
 */
void ADDSPP (void *op1, void *op2, void *op3, void *op4) {

  char *target_ptr = NULL;
  char *source_ptr = NULL;
  int displacement = *(int*)op3;

  read_ptr(op1, &target_ptr);
  read_ptr(op2, &source_ptr);

  target_ptr = source_ptr + displacement;

  store_ptr(op1, &target_ptr);
}

/**
 * 11. SUBSPP
 *
 * @param [in] op1, target pointer
 * @param [in] op2, source pointer
 * @param [in] op3, bin(4) decremention
 */
void SUBSPP (void *op1, void *op2, void *op3, void *op4) {

  char *target_ptr = NULL;
  char *source_ptr = NULL;
  int displacement = *(int*)op3;

  read_ptr(op1, &target_ptr);
  read_ptr(op2, &source_ptr);

  target_ptr = source_ptr - displacement;

  store_ptr(op1, &target_ptr);
}

/**
 * 12. SUBSPPFO
 *
 * @param [out] op1, bin(4) offset difference
 * @param [in] op2, minuend pointer
 * @param [in] op3, subtrahend pointer
 */
void SUBSPPFO (void *op1, void *op2, void *op3, void *op4) {

  char *spp1 = NULL;
  char *spp2 = NULL;
  int *offset = (int*)op1;

  read_ptr(op2, &spp1);
  read_ptr(op3, &spp2);

  *offset = spp1 - spp2;
}

/**
 * 13. STSPPO
 *
 * @param [out] op1, bin(4) offset value of input space pointer
 * @param [in] op2, space pointer
 */
void STSPPO (void *op1, void *op2, void *op3, void *op4) {

  void *spp = NULL;
  int *offset = (int*)op1;
  matptr_spp_t tmpl;

  read_ptr(op2, &spp);

  memset(&tmpl, 0, sizeof(matptr_spp_t));
  tmpl.bytes_in = sizeof(matptr_spp_t);
  _MATPTR(&tmpl, &spp);

  *offset = tmpl.offset;
}

/**
 * 14. SETSPPO
 *
 * @param [out] op1, space pointer
 * @param [in] op2, bin(4) offset value
 */
void SETSPPO (void *op1, void *op2, void *op3, void *op4) {
  char *spp = NULL;
  int *offset = (int*)op2;
  matptr_spp_t tmpl;
  int diff = 0;

  read_ptr(op1, &spp);

  // get current offset of target space pointer
  memset(&tmpl, 0, sizeof(matptr_spp_t));
  tmpl.bytes_in = sizeof(matptr_spp_t);
  _MATPTR(&tmpl, &spp);

  // set input offset value into target space pointer
  diff = *offset - tmpl.offset;
  spp += diff;

  // store modified SPP back
  store_ptr(op1, &spp);
}

/**
 * 15. NEW_PTR. contruct and return a new NULL pointer
 *
 * @param [out] op1, pointer ID of the newly allocated pointer.
 */
void NEW_PTR (void *op1, void *op2, void *op3, void *op4) {

  void *ptr = NULL;
  store_ptr(op1, &ptr);
}

/**
 * 16. CMPPTRT
 *
 * @param [in] op1, input pointer
 * @param [in] op2, char(1) pointer type
 * @param [out] op2, bin(4) comparison result. 1 if pointer is of specified type, otherwise 0.
 */
# pragma linkage(_CMPPTRT, builtin)
int _CMPPTRT(char /* pointer type */, void * /* pointer */);

void CMPPTRT (void *op1, void *op2, void *op3, void *op4) {

  void *ptr = NULL;
  char *ptr_type = (char*)op2;
  int *result = (int*)op3;

  read_ptr(op1, &ptr);
  *result = _CMPPTRT(ptr_type[0], ptr);
}
