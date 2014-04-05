/**
 * @file cmpla02.c
 *
 * Compare the addressabilities contained in 2 space pointers and
 * return the comparison result.
 *
 * Article ID: CMPLA
 */

# include <stdlib.h>

/**
 * Compare the addressabilities contained in 2 space pointers
 */
int cmp_spp(void *ptra, void* ptrb) {
  int r = 0;
  if(ptra > ptrb)          // STMT: 2
    r = 'G';               // STMT: 3
  else if (ptra < ptrb)    // STMT: 4
    r = 'L';               // STMT: 5
  else if (ptra == ptrb)   // STMT: 6
    r = 'E';               // STMT: 7
  else
    r = 'U';               // STMT: 8
  return r;
}

int main(int argc, char *argv[]) {
  void **ptra, **ptrb;
  char *rtn;

  if(argc < 4) {
    // Error handling
    return -1;
  }

  ptra = (void**)argv[1];
  ptrb = (void**)argv[2];
  rtn = argv[3];
  *rtn = cmp_spp(*ptra, *ptrb);

  return 0;
}
