/**
 * @file oo08t1.c
 *
 * Test of the LCKLCK program.
 */

# include <stdlib.h>
# include <string.h>

# pragma linkage(LCKLCK, OS)
void LCKLCK(void **obj, char *lock_state, char *flag);

# pragma linkage(_RSLVSP2, builtin)
void _RSLVSP2(void**, void*);

int main(int argc, char *argv[]) {

  void *ctx = NULL;
  char lck_sts = 0x9;
  char flag = 'L';
  char rt[34] = {0};
  char *lib = NULL;
  if(argc < 2) {
    return -1;
  }
  lib = argv[1];

  memcpy(rt, "\x04\x01", 2);
  memset(rt + 2, 0x40, 30);
  memcpy(rt + 2, lib, strlen(lib));
  _RSLVSP2(&ctx, rt);

  LCKLCK(&ctx, &lck_sts, &flag);
  return 0;
}
