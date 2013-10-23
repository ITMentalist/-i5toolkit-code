/**
 * @file lspco02.c
 * System built-in _LSPCO, and NMI instruction LSPCO
 */

# include <stdlib.h>
# include <string.h>
# include <stdio.h>
# include <mih/cvthc.h>

# pragma linkage(_LSPCO, builtin)
void* _LSPCO(void*);

# pragma linkage(_MODASA, builtin)
void *_MODASA(unsigned);

static void *p = NULL;

void func() {
  p = _LSPCO(p);  // stmt 1
}

int main() {
  char addr[33] = {0};
  p = _MODASA(0x100);
  func();
  cvthc(addr, &p, 32);
  printf("SPP: %s\x25", addr);
  return 0;
}
