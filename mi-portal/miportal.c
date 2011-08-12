/**
 * @file miportal.c
 *
 * @todo Type of the MI object to store pointers requested by clients
 * @todo call MIPORTAL for 256 times (看 auto-extend)
 * @todo 目前还没有设计回收 PTR-SPC 的接口 (for clients)
 */

# include <stdlib.h>
# include <stdio.h>
# include <string.h>

# include "inst-tmpl.h"

/// @todo prototypes of MI instructions should be moved to other source unit
# pragma linkage (_SETSPPFP, builtin)
void* _SETSPPFP(void*);

# pragma linkage (_CPYBWP, builtin)
void _CPYBWP(void*, void*, int);

# pragma linkage (_CRTS, builtin)
void _CRTS(void*, void*);

/**
 * Creates PTR-SPC (space object to store pointers requested by clients
 * @post static SYP _ptr_spc
 */
void create_ptr_spc();
# define MIPORTAL_PTR_SPC "miportal-ptr-space            "
# define MIPORTAL_HDR_LEN 32

/// @todo move type-definitions elsewhere
typedef _Packed struct tag_ptr_spc_hdr {
  unsigned cur_off;  // current offset value, 32 when PTR-SPC is created
  char reserved[MIPORTAL_HDR_LEN - 4];
} ptr_spc_hdr_t;

typedef _Packed struct tag_ptr {
  void *ptr;
} ptr_t;

/**
 * Stores a pointer into PTR-SPC
 *
 * @param pptr, address of the pointer to store into PTR-SPC
 * @return offset of the stored pointer
 * @pre _ptr_spc
 */
unsigned store_ptr(void **pptr);

void MATMATR (void*, void*, void*, void*);
void GENUUID (void*, void*, void*, void*);
void RSLVSP2 (void*, void*, void*, void*);
void ENQ (void*, void*, void*, void**);
void DEQWAIT (void*, void*, void*, void*);

typedef void proc_t(void*, void*, void*, void*);
static proc_t* proc_arr[512] = {
  NULL,
  &MATMATR, &GENUUID, &RSLVSP2, &ENQ, &DEQWAIT,
  NULL
};

/**
 * System pointer to pointer-space. This space object is created to
 * store pointers requested by clients of MIPORTAL.
 *
 * @remark To allowed _ptr_spc be used crossing calls to MIPORTAL,
 *         MIPORTAL should be compiled to use a persistend ACTGRP.
 */
static void *_ptr_spc = NULL;
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
  int *offset = (int*)op1;

  _RSLVSP2(&syp, op2);

  // return the offset of SYP into PTR-SPC as op1
  *offset = store_ptr(&syp);
}

void create_ptr_spc() {

  crts_t tmpl;
  size_t len = sizeof(tmpl);
  ptr_spc_hdr_t* hdr;

  memset(&tmpl, 0, len);
  tmpl.bytes_in = len;
  memcpy(tmpl.obj_type, "\x19\xEF", 2); // hex 19EF
  memcpy(tmpl.obj_name, MIPORTAL_PTR_SPC, 30);
  memcpy(tmpl.crt_opt,
         "\x40\x02\x00\x00",
         4);
  /*
b'01000000,00000010,000000...', hex 4002,0000
  temparory, variable-length, not-in-context, no-ag, --, no-public-auth, no-init-owner, ----, not-set-public-auth, init-spc, auto-extend, hdw-protect=00, process-temporary-space-accounting=0(yes), ---, enforce-hwd-protection, bits 22-31: reserved
  */
  tmpl.spc_size = 0x1000; // 4K
  memcpy(tmpl.perf_cls, "\x30\x00\x00\x00", 4);
  /*
    b'00110000,...'
    bit 2. spread-the-space-object-among-storage-devices=1 (yes)
    bit 3. machine-chooses-space-alignment=1 (yes)
   */

  _CRTS(&_ptr_spc, &tmpl);

  // write initial header into PTR-SPC
  hdr = (ptr_spc_hdr_t*)_SETSPPFP(_ptr_spc);
  hdr->cur_off = MIPORTAL_HDR_LEN;

  // for debug reason, log _ptr_spc to somewhere
  memcpy(_dbg, &_ptr_spc, 16);
}

unsigned store_ptr(void **pptr) {

  void *spp = NULL;
  ptr_spc_hdr_t *hdr = NULL;
  void *pos = NULL;
  unsigned r = 0;

  // make sure PTR-SPC exists
  if(_ptr_spc == NULL)
    create_ptr_spc();

  spp = _SETSPPFP(_ptr_spc);
  hdr = (ptr_spc_hdr_t*)spp;
  r = hdr->cur_off;
  pos = (char*)spp + r;
  _CPYBWP(pos, pptr, 16);
  hdr->cur_off += 16;

  return r;
}

/// index = 4. _ENQ
# pragma linkage (_ENQ, builtin)
void _ENQ(void*, void*, void*);

void ENQ (void *op1, void *op2, void *op3, void *op4) {

  unsigned *offset;
  void *spp;
  ptr_t* syp;

  // locate SYP in PTR-SPC
  offset = (unsigned*)op1;
  spp = _SETSPPFP(_ptr_spc);
  spp = (char*)spp + *offset;
  syp = (ptr_t*)spp;

  // enqueue
  _ENQ(&syp->ptr, op2, op3);
}

/// index = 5, _DEQWAIT
# pragma linkage (_DEQWAIT, builtin)
void _DEQWAIT(void *prefix, void *msg, void *q);

void DEQWAIT (void *op1, void *op2, void *op3, void *op4) {

  unsigned *offset;
  void *spp;
  ptr_t* syp;

  // locate SYP in PTR-SPC
  offset = (unsigned*)op3;
  spp = (char*)_SETSPPFP(_ptr_spc) + *offset;
  syp = (ptr_t*)spp;

  // enqueue
  _DEQWAIT(op1, op2, &syp->ptr);
}
