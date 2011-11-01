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

# include <qusec.h>
# include <qmhsndpm.h>

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
 * Check number of operands to pass to a specific MI instruction
 */
void check_operand_num(int inx,     // MI Portal defined instruction index
                       int operands // number of operands passed by caller
                       );

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

void MATMATR (void*, void*, void*, void*); // 1. MATMATR
void GENUUID (void*, void*, void*, void*); // 2. GENUUID
void RSLVSP2 (void*, void*, void*, void*); // 3. RSLVSP2
void ENQ (void*, void*, void*, void**);    // 4. ENQ
void DEQWAIT (void*, void*, void*, void*); // 5. DEQWAIT

/**
 * 6. RELEASE_PTR
 *
 * @param[in] op1, 16-byte pointer ID
 */
void RELEASE_PTR (void* op1, void*, void*, void*);

// 7. space pointer operations
void SETSPPFP (void*, void*, void*, void*);

// 8. read_addr(spp, buf, len)
void READ_FROM_ADDR (void*, void*, void*, void*);
// 9. write_addr(spp, buf, len)
void WRITE_TO_ADDR (void*, void*, void*, void*);
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
// 17. SETSPFP
void SETSPFP (void*, void*, void*, void*);
// 18. RSLVSP4
void RSLVSP4 (void*, void*, void*, void*);
// 19. RSLVSP2_H
void RSLVSP2_H (void*, void*, void*, void*);
// 20. RSLVSP4_H
void RSLVSP4_H (void*, void*, void*, void*);
// 21. CALLPGMV
void CALLPGMV (void*, void*, void*, void*);
// 22. CRTS
void CRTS (void*, void*, void*, void*);
// 22. CRTS_H
void CRTS_H (void*, void*, void*, void*);
// 24. DESS
void DESS (void*, void*, void*, void*);
// 25. MATS
void MATS (void*, void*, void*, void*);
// 26. MATS_H
void MATS_H (void*, void*, void*, void*);
// 27. MODS1
void MODS1 (void*, void*, void*, void*);
// 28. MODS2
void MODS2 (void*, void*, void*, void*);
// 29 (hex 001D). DUP_PTR
void DUP_PTR (void*, void*, void*, void*);
// 30 (hex 001E). CPYBWP
void CPYBWP (void*, void*, void*, void*);
// 31 (hex 001F). ALCHSS
void ALCHSS (void*, void*, void*, void*);
// 32 (hex 0020). CRTHS
void CRTHS (void*, void*, void*, void*);
// 33 (hex 0021). DESHS
void DESHS (void*, void*, void*, void*);
// 34 (hex 0022). FREHSS
void FREHSS (void*, void*, void*, void*);
// 35 (hex 0023). REALCHSS
void REALCHSS (void*, void*, void*, void*);
// 36 (hex 0024). SETHSSMK
void SETHSSMK (void*, void*, void*, void*);
// 37 (hex 0025). FREHSSMK
void FREHSSMK (void*, void*, void*, void*);
// 38 (hex 0026). MATHSAT_H
void MATHSAT_H (void*, void*, void*, void*);
// 39 (hex 0027). MATCTX1_H
void MATCTX1_H (void*, void*, void*, void*);
// 40 (hex 0028). MATCTX2_H
void MATCTX2_H (void*, void*, void*, void*);
// 41 (hex 0029). QTEMPPTR
void QTEMPPTR (void*, void*, void*, void*);
// 42 (hex 002A). CRTMTX
void CRTMTX (void*, void*, void*, void*);
// 43 (hex 002B). DESMTX
void DESMTX (void*, void*, void*, void*);
// 44 (hex 002C). LOCKMTX
void LOCKMTX (void*, void*, void*, void*);
// 45 (hex 002D). UNLKMTX
void UNLKMTX (void*, void*, void*, void*);

// Independent Indext Managment
// 46 (hex 002E). CRTINX
void CRTINX (void*, void*, void*, void*);
// 47 (hex 002F). DESINX
void DESINX (void*, void*, void*, void*);

typedef void proc_t(void*, void*, void*, void*);

static proc_t* _proc_arr[512] = {
  NULL,
  &MATMATR, &GENUUID, &RSLVSP2, &ENQ, &DEQWAIT, &RELEASE_PTR,
  &SETSPPFP, &READ_FROM_ADDR, &WRITE_TO_ADDR, &ADDSPP, &SUBSPP, &SUBSPPFO, &STSPPO, &SETSPPO,
  &NEW_PTR, &CMPPTRT, &SETSPFP, &RSLVSP4, &RSLVSP2_H, &RSLVSP4_H,
  &CALLPGMV, &CRTS, &CRTS_H, &DESS, &MATS, &MATS_H, &MODS1, &MODS2,
  &DUP_PTR, &CPYBWP, &ALCHSS, &CRTHS, &DESHS, &FREHSS, &REALCHSS,
  &SETHSSMK, &FREHSSMK, &MATHSAT_H, &MATCTX1_H, &MATCTX2_H,
  &QTEMPPTR,
  &CRTMTX, &DESMTX, &LOCKMTX, &UNLKMTX,
  &CRTINX, &DESINX,
  NULL
};

static unsigned short _arg_num_arr[512] = {
  0xFFFF,
  2, 1, 2, 3, 3, 1,
  2, 3, 3, 3, 3, 3, 2, 2,
  1, 3, 2, 3, 2, 3,
  3, 2, 2, 1, 2, 2, 2, 2,
  2, 3, 3, 2, 1, 1, 2,
  2, 1, 3, 2, 3,
  1,
  3, 3, 3, 2,  // CRTMTX, ...
  2, 1,        // CRTINX, DESINX, ...
  0xFFFF
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

  // check number of operands for target MI instruction
  check_operand_num(inx, argc - 2);

  _proc_arr[inx](argv[2], argv[3], argv[4], argv[5]);

  return 0;
}

/// @todo check for upper limit of instruction index
void check_operand_num(int inx,     // MI Portal defined instruction index
                       int operands // number of operands passed by caller
                       ) {

  Qus_EC_t ec;
  char msg[196] = {0};
  char key[4] = {0};

  if(operands == _arg_num_arr[inx])
    return;

  sprintf(msg,
          "Number of operands passed to MI Portal "     \
          "not valid. Instruction index is hex %04X. "  \
          "Number of operands passed is %d, which is "   \
          "expected to be %d.",
          inx, operands, _arg_num_arr[inx]
          );
  memset(&ec, 0, sizeof(Qus_EC_t));
  ec.Bytes_Provided = sizeof(Qus_EC_t);
  QMHSNDPM("CPF9898",
           "QCPFMSG   QSYS      ",
           msg,
           strlen(msg),
           "*ESCAPE   ",
           "*PGMBDY   ",
           1,
           key,
           &ec
           );
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

/**
 * 3. RSLVSP2
 *
 * @param [out] Pointer ID of resolved system pointer
 * @param [in]  Resolve option
 */
void RSLVSP2 (void *op1, void *op2, void *op3, void *op4) {

  void *syp = NULL; // system pointer to the MI obj to resolve
  void *old_syp = NULL;

  _RSLVSP2(&syp, op2);

  if(read_ptr(op1, &old_syp) == 0)
    update_ptr(op1, &syp);
  else
    store_ptr(op1, &syp);
}

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

int update_ptr(char *ptr_id, void **pptr) {

  genuuid_t id;
  inx_oplist_t oplist;
  ptr_inx_entry_t ent;

  // make sure PTR-INX exists
  if(_ptr_inx == NULL)
    return -1;

  memset(&oplist, 0, sizeof(inx_oplist_t));
  memcpy(ent.key, ptr_id, 16);
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
  char search_key[16] = {0};

  if(_ptr_inx == NULL)
    return -1;

  // remove inx entry by 16-byte ptr_id
  memset(&oplist, 0, sizeof(inx_oplist_t));
  memcpy(oplist.rule, "\x00\x01", 2);  // EQ
  oplist.occ_cnt = 1;
  oplist.arg_len = 16; // length of search-key
  memcpy(search_key, ptr_id, 16);
  _RMVINXEN1(&ent, &_ptr_inx, &oplist, search_key);

  if(oplist.rtn_cnt > 0) {
    *pptr = ent.ptr;
    memset(ptr_id, 0x00, 16); // clear pointer ID
  } else {
    *pptr = NULL;
    return -1;
  }

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

  if(oplist.rtn_cnt > 0)
    *pptr = ent.ptr;
  else {
    *pptr = NULL;
    return -1;
  }

  return 0;
}

/**
 * index = 4. ENQ
 *
 * @param [in] Pointer ID of system pointer to queue object
 * @param [in] Message prefix
 * @param [in] Message text
 *
 * @todo ENQ_H (for using of enqueue messages containing pointers)
 */
void ENQ (void *op1, void *op2, void *op3, void *op4) {

  void* syp;

  // locate SYP in PTR-INX
  if(read_ptr(op1, &syp) != 0)
    return;

  // enqueue
  _ENQ(&syp, op2, op3);
}

/// index = 5, _DEQWAIT
void DEQWAIT (void *op1, void *op2, void *op3, void *op4) {

  void* syp;

  // locate SYP in PTR-INX
  if(read_ptr(op3, &syp) != 0)
    return;

  // deq
  _DEQWAIT(op1, op2, &syp);
}

/**
 * index = 6, RELEASE_PTR
 *
 * @param [in] Pointer ID of the ptr to release
 */
void RELEASE_PTR (void *op1, void *op2, void *op3, void *op4) {

  void *ptr = NULL; // released MI pointer

  release_ptr(op1, &ptr);
}

/**
 * index = 7, SETSPPFP
 *
 * @param [out] op1. Pointer ID of returned space pointer
 * @param [in]  op2. Pointer ID of source pointer
 */
void SETSPPFP (void *op1, void *op2, void *op3, void *op4) {

  void *spp = NULL;
  void *src_ptr = NULL;
  void *old_spp = NULL;

  if(read_ptr(op2, &src_ptr) != 0)
    return;

  spp = _SETSPPFP(src_ptr);

  if(read_ptr(op1, &old_spp) == 0)
    update_ptr(op1, &spp);
  else
    store_ptr(op1, &spp);
}

/**
 * index = 8, read from an SLS address pointed to by a space pointer
 *
 * @param [in] op1, ID of the source space pointer
 * @param [out] op2, buffer provided by client
 * @param [in] op3, number of bytes to read
 */
void READ_FROM_ADDR (void *op1, void *op2, void *op3, void *op4) {

  void *spp = NULL;
  unsigned len = *(unsigned*)op3;

  if(read_ptr(op1, &spp) != 0)
    return;

  memcpy(op2, spp, len);
}

/**
 * index = 9, write to an SLS address pointed to by a space pointer
 *
 * @param [in] op1, ID of the target space pointer
 * @param [in] op2, buffer provided by client
 * @param [in] op3, Ubin(4) number of bytes to write
 */
void WRITE_TO_ADDR (void *op1, void *op2, void *op3, void *op4) {

  void *spp = NULL;
  unsigned len = *(unsigned*)op3;

  if(read_ptr(op1, &spp) != 0)
    return;

  memcpy(spp, op2, len);
}

/**
 * 10. ADDSPP
 *
 * @param [in] op1, target pointer
 * @param [in] op2, source pointer
 * @param [in] op3, bin(4) incremention
 *
 * @attention ADDSPP and SUBSPP generate a new space pointer and hence
 * should be released by calling RELEASE_PTR after using
 */
void ADDSPP (void *op1, void *op2, void *op3, void *op4) {

  char *target_ptr = NULL;
  char *source_ptr = NULL;
  int displacement = *(int*)op3;

  // source spp must exists
  if(read_ptr(op2, &source_ptr) != 0)
    return;

  if(read_ptr(op1, &target_ptr) != 0)
    store_ptr(op1, &target_ptr);

  target_ptr = source_ptr + displacement;

  update_ptr(op1, &target_ptr);
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

  // source spp must exists
  if(read_ptr(op2, &source_ptr) != 0)
    return;

  if(read_ptr(op1, &target_ptr) != 0)
    store_ptr(op1, &target_ptr);

  target_ptr = source_ptr - displacement;

  update_ptr(op1, &target_ptr);
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

  if(read_ptr(op2, &spp1) != 0 ||\
     read_ptr(op3, &spp2) != 0)
    return;

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

  if(read_ptr(op2, &spp) != 0)
    return;

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

  if(read_ptr(op1, &spp) != 0)
    return;

  // get current offset of target space pointer
  memset(&tmpl, 0, sizeof(matptr_spp_t));
  tmpl.bytes_in = sizeof(matptr_spp_t);
  _MATPTR(&tmpl, &spp);

  // set input offset value into target space pointer
  diff = *offset - tmpl.offset;
  spp += diff;

  // store modified SPP back
  update_ptr(op1, &spp);
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
void CMPPTRT (void *op1, void *op2, void *op3, void *op4) {

  void *ptr = NULL;
  char *ptr_type = (char*)op2;
  int *result = (int*)op3;

  if(read_ptr(op1, &ptr) != 0)
    return;

  *result = _CMPPTRT(ptr_type[0], ptr);
}

/**
 * 17. Set System Pointer from Pointer (SETSPFP)
 *
 * @param [in] op1, source pointer
 * @param [in] op2, pointer-ID of the returned pointer
 */
void SETSPFP (void *op1, void *op2, void *op3, void *op4) {

  void *syp = NULL;
  void *src_ptr = NULL;
  void *old_syp = NULL;

  if(read_ptr(op1, &src_ptr) != 0)
    return;

  syp = _SETSPFP(src_ptr);

  if(read_ptr(op2, &old_syp) == 0)
    update_ptr(op2, &syp);
  else
    store_ptr(op2, &syp);
}

/**
 * 18. RSLVSP4
 *
 * @param [out] Pointer ID of resolved system pointer
 * @param [in]  Resolve option
 * @param [in]  Pointer ID of context object
 */
# pragma linkage (_RSLVSP4, builtin)
void _RSLVSP4(void**, // address of returned SYP to target MI object
              void*,  // resolve template
              void**); // address of SYP to a context object

void RSLVSP4 (void *op1, void *op2, void *op3, void *op4) {

  void *ctx = NULL;
  void *syp = NULL; // system pointer to the MI obj to resolve
  void *old_syp = NULL;

  if(read_ptr(op3, &ctx) != 0) // invalid ptr-id of syp to ctx obj
    return;

  _RSLVSP4(&syp, op2, &ctx);

  // return the offset of SYP into PTR-INX as op1
  if(read_ptr(op1, &old_syp) == 0)
    update_ptr(op1, &syp);
  else
    store_ptr(op1, &syp);
}

/**
 * index = 19. RSLVSP2_H
 *
 * @param [out] Pointer ID of resolved system pointer
 * @param [in]  Pointer ID of space pointer addressing the resolve option
 *
 * @remark Unlike RSLVSP2,, when using RSLVSP2_H, operand 2 is a space
 * pointer addressing the prepared resolved option data allocated at
 * the server side.
 *
 * @excample test/cmdline.clp
 */
void RSLVSP2_H (void *op1, void *op2, void *op3, void *op4) {

  void *syp = NULL; // system pointer to the MI obj to resolve
  void *old_syp = NULL;
  void *opt_ptr = NULL;

  if(read_ptr(op2, &opt_ptr) != 0)
    return;

  _RSLVSP2(&syp, opt_ptr);

  // return the offset of SYP into PTR-INX as op1
  if(read_ptr(op1, &old_syp) == 0)
    update_ptr(op1, &syp);
  else
    store_ptr(op1, &syp);
}

/**
 * index = 20. RSLVSP4_H
 *
 * @param [out] Pointer ID of resolved system pointer
 * @param [in]  Pointer ID of space pointer addressing the resolve option
 * @param [in]  Pointer ID of a system pointer to the target context object
 *
 * @remark Unlike RSLVSP4,, when using RSLVSP4_H, operand 2 is a space
 * pointer addressing the prepared resolved option data allocated at
 * the server side.
 */
void RSLVSP4_H (void *op1, void *op2, void *op3, void *op4) {

  void *ctx = NULL;
  void *syp = NULL; // system pointer to the MI obj to resolve
  void *old_syp = NULL;
  void *opt_ptr = NULL;

  if(read_ptr(op2, &opt_ptr) != 0)
    return;

  if(read_ptr(op3, &ctx) != 0) // invalid ptr-id of syp to ctx obj
    return;

  _RSLVSP4(&syp, opt_ptr, &ctx);

  // return the offset of SYP into PTR-INX as op1
  if(read_ptr(op1, &old_syp) == 0)
    update_ptr(op1, &syp);
  else
    store_ptr(op1, &syp);
}

/**
 * 21. CALLPGMV
 *
 * @param [in] Pointer ID to *PGM object
 * @param [in] Array of pointer IDs of space pointer that addressing each program argument
 * @param [in] Ubin(4) number of aruments
 *
 * @excample test/cmdline.clp
 */
void CALLPGMV (void *op1, void *op2, void *op3, void *op4) {

  void *pgm = NULL;
  void *argarr = NULL; // argument arrary
  unsigned args = 0;
  int i = 0;
  char *pos = NULL;
  void *argptr = NULL;
  char *ptrid = NULL;

  if(read_ptr(op1, &pgm) != 0) // retrieve syp to pgm
    return;

  // prepare arg-array
  args = *(unsigned*)op3;
  argarr = malloc(16 * args);
  pos = (char*)argarr;
  ptrid = (char*)op2;
  for(i = 0; i < args; i++, pos += 16, ptrid += 16) {
    if(read_ptr(ptrid, &argptr) != 0) {
      free(argarr);
      return;
    }
    memcpy(pos, &argptr, 16);
  }

  // call target program
  _CALLPGMV(&pgm, argarr, args);

  free(argarr);
}

/**
 * 22 (hex 0016). CRTS
 *
 * @param [out] Pointere ID of the system pointer to the created space object
 * @param [in] Creation template
 */
void CRTS (void *op1, void *op2, void *op3, void *op4) {

  void *syp = NULL; // system pointer to the created space object
  void *old_syp = NULL;
  void *crt_tmpl = NULL;

  crt_tmpl = malloc(_CRTS_TMPL_LEN);
  memcpy(crt_tmpl, op2, _CRTS_TMPL_LEN);
  _CRTS(&syp, crt_tmpl);
  memcpy(op2, crt_tmpl, _CRTS_TMPL_LEN);
  free(crt_tmpl);

  if(read_ptr(op1, &old_syp) == 0)
    update_ptr(op1, &syp);
  else
    store_ptr(op1, &syp);
}

/**
 * 23 (hex 0017). CRTS_H
 *
 * @param [out] Pointere ID of the system pointer to the created space object
 * @param [in] Pointer ID of the space pointer addressing the creationg template (allocated at server side)
 */
void CRTS_H (void *op1, void *op2, void *op3, void *op4) {

  void *syp = NULL; // system pointer to the created space object
  void *old_syp = NULL;
  void *tmpl_spp = NULL;

  if(read_ptr(op2, &tmpl_spp) != 0) // invalid ptr ID
    return;

  _CRTS(&syp, tmpl_spp);

  if(read_ptr(op1, &old_syp) == 0)
    update_ptr(op1, &syp);
  else
    store_ptr(op1, &syp);
}

/**
 * 24 (hex 0018). DESS
 *
 * @param [in] Pointer ID of the SYP to the space object to destroy
 */
void DESS (void *op1, void *op2, void *op3, void *op4) {

  void *syp = NULL;

  if(read_ptr(op1, &syp) != 0)
    return;

  _DESS(&syp);
}

/**
 * 25 (hex 0019). MATS
 *
 * @param [inout] 116-byte materialization template
 * @param [in] Pointer ID of the SYP to the space object
 */
void MATS (void *op1, void *op2, void *op3, void *op4) {

  void *syp = NULL;
  void *mat_tmpl = NULL;

  if(read_ptr(op2, &syp) != 0)
    return;

  mat_tmpl = malloc(_CRTS_TMPL_LEN);
  memcpy(mat_tmpl, op2, _CRTS_TMPL_LEN);
  _MATS(mat_tmpl, &syp);
  memcpy(op2, mat_tmpl, _CRTS_TMPL_LEN);
  free(mat_tmpl);
}

/**
 * 26 (hex 001A). MATS_H
 *
 * @param [in] Pointer ID of the SPP to the materialization template (allocated at server side)
 * @param [in] Pointer ID of the SYP to the space object
 */
void MATS_H (void *op1, void *op2, void *op3, void *op4) {

  void *syp = NULL;
  void *tmpl_spp = NULL;

  if(read_ptr(op1, &tmpl_spp) != 0)
    return;

  if(read_ptr(op2, &syp) != 0)
    return;

  _MATS(tmpl_spp, &syp);
}

/**
 * 27 (hex 001B). MODS1
 * Modify space size
 *
 * @param [in] Pointer ID of the SYP to target space object
 * @param [in] Bin(4) space size
 */
void MODS1 (void *op1, void *op2, void *op3, void *op4) {

  void *syp = NULL;

  if(read_ptr(op1, &syp) != 0)
    return;

  _MODS1(&syp, op2);
}

/**
 * 28 (hex 001C). MODS2
 * Modify space attributes (including space size)
 *
 * @param [in] Pointer ID of the SYP to target space object
 * @param [in] 28-byte modification template
 */
void MODS2 (void *op1, void *op2, void *op3, void *op4) {

  void *syp = NULL;

  if(read_ptr(op1, &syp) != 0)
    return;

  _MODS2(&syp, op2);
}

/**
 * 29 (hex 001D). Duplicate an MI pointer at the server side
 *
 * @param [out] Pointer ID of the duplicated pointer
 * @param [in]  Pointer ID of the source pointer
 */
void DUP_PTR (void *op1, void *op2, void *op3, void *op4) {

  void *newptr = NULL;
  void *srcptr = NULL;
  void *old = NULL;

  // load source pointer
  if((read_ptr(op2, &srcptr)) != 0)
    return;

  _CPYBWP(&newptr, &srcptr, 16);

  if(read_ptr(op1, &old) == 0)
    update_ptr(op1, &newptr);
  else
    store_ptr(op1, &newptr);
}

/**
 * 30 (hex 001E). CPYBWP
 *
 * Copy specified length of data addressed by source space pointer to
 * the storage addressed by target space pointer. Pointer data items
 * can be successfully duplicated via this instruction.
 *
 * @attention This instruction is to copy data between server-side
 * storage. To copy client-side storage to/from server-side storage,
 * use support functions WRITE_TO_ADDR and READ_FROM_ADDR
 * respectively.
 *
 * @attention Either the source spcptr or the target spcptr must be a
 * valid space pointer.
 *
 * @param [int] Pointer ID of the target space pointer
 * @param [in]  Pointer ID of the source space pointer
 * @param [in]  UBin(4). Number of bytes to copy
 */
void CPYBWP (void *op1, void *op2, void *op3, void *op4) {

  void *tgtptr = NULL;
  void *srcptr = NULL;
  unsigned len = *(unsigned*)op3;

  // load source pointer
  if((read_ptr(op1, &tgtptr)) != 0 || \
     (read_ptr(op2, &srcptr)) != 0)
    return;

  _CPYBWP(&tgtptr, &srcptr, len);
}

/**
 * 31 (hex 001F). ALCHSS
 *
 * Allocate heap storage on an activation-group (AGP) based heap space.
 *
 * @param [in/out] Pointer ID to a space pointer addressing the newly
 * allocated heap storage.
 * @param [in] Bin(4). Heap ID. A value of zero represent the default
 * heap space of an AGP.
 * @param [in] Bin(4). Number of bytes to allocate. The possible
 * maximum single allocation size for a Single Level Store (SLS) heap
 * is 16M - 1 Page.
 */
void ALCHSS (void *op1, void *op2, void *op3, void *op4) {

  void *spp = NULL;
  int heap_id = *(int*)op2;
  int len = *(int*)op3;
  void *oldptr = NULL;

  spp = _ALCHSS(heap_id, len);

  // store SPP to allocated heap storage
  if(read_ptr(op1, &oldptr) == 0)
    update_ptr(op1, &spp);
  else
    store_ptr(op1, &spp);
}

/**
 * 32 (hex 0020). CRTHS
 * Create AGP-based heap space.
 *
 * @remark Heap managemnet MI instructions works with Single Level Store (SLS) heap spaces.
 *
 * @param [out] Bin(4). Heap ID of the created heap space.
 * @param [in]  96-byte heap creation template.
 */
void CRTHS (void *op1, void *op2, void *op3, void *op4) {

  _CRTHS(op1, op2);
}

/**
 * 33 (hex 0021). DESHS
 * Destroy AGP-based heap space.
 *
 * @param [in] Bin(4). Heap ID of the created heap space.
 */
void DESHS (void *op1, void *op2, void *op3, void *op4) {

  _DESHS(op1);
}

/**
 * 34 (hex 0022). FREHSS
 *
 * Free allocated heap storage.
 *
 * @param [in] Pointer ID to the space pointer addressing the
 * beginning of allocated heap storage.
 *
 * @remark The entire space allocation is de-allocated; partial
 * de-allocation is not supported.
 */
void FREHSS (void *op1, void *op2, void *op3, void *op4) {

  void *spp = NULL;

  if((read_ptr(op1, &spp)) != 0)
    return;

  _FREHSS(spp);
  release_ptr(op1, &spp);
}

/**
 * 35 (hex 0023). REALCHSS
 *
 * Reallocate heap storage on an activation-group (AGP) based heap space.
 *
 * @param [in] Pointer ID to a space pointer addressing the reallocated heap storage.
 * @param [in] Bin(4). Number of bytes to allocate. The possible
 * maximum single allocation size for a Single Level Store (SLS) heap
 * is 16M - 1 Page.
 */
void REALCHSS (void *op1, void *op2, void *op3, void *op4) {

  void *spp = NULL;
  int len = *(int*)op2;

  if(read_ptr(op1, &spp) != 0)
    return;

  spp = _REALCHSS(spp, len);

  // store SPP to reallocated heap storage
  update_ptr(op1, &spp);
}

/**
 * 36 (hex 0024). SETHSSMK
 *
 * Set AGP-based heap space storage mark
 *
 * @param [in/out] Pointer ID to a space pointer serving as a mark ID
 * @param [in] Bin(4). Heap ID
 */
void SETHSSMK (void *op1, void *op2, void *op3, void *op4) {

  void *mark = NULL;
  int *heap_id = (int*)op2;

  _SETHSSMK(&mark, heap_id);

  // stored returned mark ID pointer
  if(read_ptr(op1, &mark) == 0)
    update_ptr(op1, &mark);
  else
    store_ptr(op1, &mark);
}

/**
 * 37 (hex 0025). FREHSSMK
 *
 * Free AGP-based heap space storage mark
 *
 * @param [in/out] Pointer ID to a space pointer serving as a mark ID
 * @post The input mark ID pointer is released on return.
 */
void FREHSSMK (void *op1, void *op2, void *op3, void *op4) {

  void *mark = NULL;

  if((read_ptr(op1, &mark)) != 0)
    return;

  _FREHSSMK(&mark);

  // release mark ID pointer
  release_ptr(op1, &mark);
}

/**
 * 39 (hex 0027). MATHSAT_H
 *
 * Materialize AGP-based heap space attributes. Operand 1 is assumed to be allocated in server side storage
 *
 * @param [in] Pointer ID of the space pointer addressing the materialization template
 * @param [in] Heap ID template
 * @param [in] Char(1). Attribute selection
 */
void MATHSAT_H (void *op1, void *op2, void *op3, void *op4) {

  void *tmpl_spp = NULL;

  if((read_ptr(op1, &tmpl_spp)) != 0)
    return;

  _MATHSAT(tmpl_spp, op2, op3);
}

/**
 * 39 (hex 0027). MATCTX1_H
 *
 * @param [in] Pointer ID of the SPP adddressing the materialization template
 * @param [in] Materialization options
 */
void MATCTX1_H (void *op1, void *op2, void *op3, void *op4) {

  void *tmpl_spp = NULL;
  if((read_ptr(op1, &tmpl_spp)) != 0)
    return;

  QusMaterializeContext(tmpl_spp, NULL, op2);
}

/**
 * 40 (hex 0028). MATCTX2_H
 *
 * @param [in] Pointer ID of the SPP adddressing the materialization template
 * @param [in] Pointer ID of SYP to target context object
 * @param [in] Materialization options
 */
void MATCTX2_H (void *op1, void *op2, void *op3, void *op4) {

  void *tmpl_spp = NULL;
  void *ctx = NULL;

  if((read_ptr(op1, &tmpl_spp)) != 0 || \
     (read_ptr(op2, &ctx)) != 0)
    return;

  QusMaterializeContext(tmpl_spp, ctx, op3);
}

/**
 * 41 (hex 0029). QTEMPPTR
 *
 * @param [in/out] Pointer ID of the returned system pointer to QTEMP (of course, of the current MI process).
 */
void QTEMPPTR (void *op1, void *op2, void *op3, void *op4) {

  void *qtemp = NULL;

  qtemp = _QTEMPPTR();

  // update or store qtemp
  if(read_ptr(op1, &qtemp) == 0)
    update_ptr(op1, &qtemp);
  else
    store_ptr(op1, &qtemp);
}

/**
 * 42 (hex 002A). CRTMTX
 *
 * Create pointer-based mutex
 *
 * @param [in] Pointer ID of an existing space pointer. The created
 *              mutex (a synchronization pointer) will be put into
 *              storage addressed by this space pointer.
 * @param [in] 32-byte mutex creation template
 * @param [out] Bin(4) result code
 */
void CRTMTX (void *op1, void *op2, void *op3, void *op4) {

  void *mtx_spp = NULL;
  int *rtn = (int*)op3;

  if(read_ptr(op1, &mtx_spp) != 0)
    return;

  *rtn = _CRTMTX(mtx_spp, op2);
}

/**
 * 43 (hex 002B). DESMTX
 *
 * Destroy pointer-based mutex
 *
 * @param [in] Pointer ID of an space pointer addressing the control
 *             area (a synchronization pointer) of a pointer-based
 *             mutex
 * @param [in] Bin(4) mutex destroy template, must be zero
 * @param [out] Bin(4) result code
 */
void DESMTX (void *op1, void *op2, void *op3, void *op4) {

  void *mtx_spp = NULL;
  int *rtn = (int*)op3;

  if(read_ptr(op1, &mtx_spp) != 0)
    return;

  *rtn = _DESMTX(mtx_spp, op2);
}

/**
 * 44 (hex 002C). LOCKMTX
 *
 * Lock pointer-based mutex
 *
 * @param [in] Pointer ID of an space pointer addressing the control
 *             area (a synchronization pointer) of a pointer-based
 *             mutex
 * @param [in] 16-byte lock request template
 * @param [out] Bin(4) result code
 */
void LOCKMTX (void *op1, void *op2, void *op3, void *op4) {

  void *mtx_spp = NULL;
  int *rtn = (int*)op3;

  if((read_ptr(op1, &mtx_spp)) != 0)
    return;

  *rtn = _LOCKMTX(mtx_spp, op2);
}

/**
 * 45 (hex 002D). UNLKMTX
 *
 * Unlock pointer-based mutex
 *
 * @param [in] Pointer ID of an space pointer addressing the control
 *        area (a synchronization pointer) of a pointer-based mutex
 * @param [out] Bin(4) result code
 */
void UNLKMTX (void *op1, void *op2, void *op3, void *op4) {

  void *mtx_spp = NULL;
  int *rtn = (int*)op3;

  if((read_ptr(op1, &mtx_spp)) != 0)
    return;

  *rtn = _UNLKMTX(mtx_spp);
}

/**
 * 46 (hex 002E). CRTINX
 *
 * Create Independent Index
 *
 * @param [out] Pointere ID of the system pointer to the created index object
 * @param [in] Creation template
 */
void CRTINX (void *op1, void *op2, void *op3, void *op4) {

  void *syp = NULL;
  void *old_syp = NULL;
  void *crt_tmpl = NULL;

  // @attention the creation template for CRTINX should be aligned to 16-byte boundaries
  crt_tmpl = malloc(_CRTINX_TMPL_LEN);
  memcpy(crt_tmpl, op2, _CRTINX_TMPL_LEN);
  _CRTINX(&syp, crt_tmpl);
  free(crt_tmpl);

  if(read_ptr(op1, &old_syp) == 0)
    update_ptr(op1, &syp);
  else
    store_ptr(op1, &syp);
}

/**
 * 47 (hex 002F). DESINX
 *
 * @param [in] Pointer ID of the SYP to the index object to destroy
 */
void DESINX (void *op1, void *op2, void *op3, void *op4) {

  void *syp = NULL;

  if(read_ptr(op1, &syp) != 0)
    return;

  _DESINX(&syp);
}
