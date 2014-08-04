/**
 * @file oo08t2.c
 *
 * Test of LCKLCK program.
 */

# include <stdlib.h>
# include <string.h>

# pragma linkage(LCKLCK, OS)
void LCKLCK(void **obj, char *lock_state, char *flag);

# pragma linkage(_RSLVSP2, builtin)
void _RSLVSP2(void**, void*);

int main(int argc, char *argv[]) {

  void *spc1909 = NULL;
  char lck_sts = 0x81;
  char flag = 'L';
  char rt[34] = {0};
  char *sbsd = NULL;
  if(argc < 2) {
    return -1;
  }
  sbsd = argv[1];

  memcpy(rt, "\x19\x09", 2);
  memset(rt + 2, 0x40, 30);
  memcpy(rt + 2, sbsd, strlen(sbsd));
  _RSLVSP2(&spc1909, rt);

  LCKLCK(&spc1909, &lck_sts, &flag);
  return 0;
}
