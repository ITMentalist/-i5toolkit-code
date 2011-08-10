/**
 * @file miportal.c
 *
 * @todo Type of the MI object to store pointers requested by clients
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

/**
 * Stores a pointer into PTR-SPC
 *
 * @param pptr, address of the pointer to store into PTR-SPC
 * @return offset of the stored pointer
 * @pre _ptr_spc
 */
unsigned store_ptr(void **pptr);


void matmatr (void*, void*, void*, void*);
void genuuid (void*, void*, void*, void*);
void rlsvsp2 (void*, void*, void*, void*);

typedef void proc_t(void*, void*, void*, void*);
static proc_t* proc_arr[512] = {
  NULL,
  &MATMATR, &GENUUID,
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

void matmatr (void *op1, void *op2, void *op3, void *op4) {
  _MATMATR1(op1, op2);
}

/// index = 2. _GENUUID
# pragma linkage (_GENUUID, builtin)
void _GENUUID(void*);

void genuuid (void *op1, void *op2, void *op3, void *op4) {
  _GENUUID(op1);
}

/// index = 3. _RSLVSP2
# pragma linkage (_RSLVSP2, builtin)
void _RSLVSP2(void*, void*);

void rlsvsp2 (void *op1, void *op2, void *op3, void *op4) {
  void *syp = NULL; // system pointer to the MI obj to resolve
  int *offset = (int*)op1;

  _RSLVSP2(&syp, op2);

  // return the offset of SYP into PTR-SPC as op1
  *offset = store_ptr(&syp);
}

void create_ptr_spc() {
  // @here
  crts_t tmpl;
}

unsigned store_ptr(void **pptr) {

  typedef _Packed struct tag_ptr_spc_hdr {
    unsigned cur_off;  // current offset value, 32 when PTR-SPC is created
    char reserved[28];
  } ptr_spc_hdr_t;

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
  pos = spp + r;
  _CPYBWP(&spp, pptr, 16);
  hdr->cur_off += 16;

  return r;
}
