/**
 * @file asa03.c
 * ID: MODASA
 */

# include <stdlib.h>

# pragma linkage(_MODASA, builtin)
void *_MODASA(int);

void *p = NULL;

int asa_op() {
  p = _MODASA(95);
  return 255;
}

int main() {
  asa_op();
  return 0;
}
