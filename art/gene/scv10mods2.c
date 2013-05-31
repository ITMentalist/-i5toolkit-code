/**
 * @file scv10mods2.c
 *
 * SCV 10 function number:
 *  - MODS1      31
 *  - MODS2     312
 */

# include <stdlib.h>

# pragma linkage(_MODS1, builtin)
void _MODS1(void**, void*);

# pragma linkage(_MODS2, builtin)
void _MODS2(void**, void*);

int main() {
  void* p = NULL;
  void* a = NULL;

  _MODS1(&p, p); // stmt num: 3
  _MODS2(&p, p); // stmt num: 4

  return 0;
}

