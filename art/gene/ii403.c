/**
 * @file ii403.c
 * _XORSTR to _ANDSTR
 * @remark article ID: CRTMD
 */

# include <stdlib.h>
# include <stdio.h>

# pragma linkage(_XORSTR, builtin)
void _XORSTR(void*, void*, void*, unsigned);

static char *_a = "ABCD"; /* hex C1C2C3C4 */
static char *_b = "abCd"; /* hex 8182C384 */
static char *_c = "    ";

void i_proc() {
  _XORSTR(_c, _a, _b, 4);
}

int main() {
  i_proc();
  printf("Result string (hex): %08X\x25", *(int*)_c);
  return 0;
}
