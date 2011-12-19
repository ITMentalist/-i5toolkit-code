/**
 * @file e014.c
 */

# include <stdlib.h>
# include <stdio.h>
# include <string.h>

# include <heap.h>

# define NL "\x25"

int main() {

  crths_t tmpl;
  unsigned l = 0;

  l = sizeof(tmpl);
  printf("sizeof crths_t: %d" NL, l);

  return 0;
}

