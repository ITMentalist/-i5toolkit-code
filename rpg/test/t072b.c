/**
 * @file t072b.c
 *
 * Called by T072. Returns a static scalar bin(4) and increaments the
 * value of it each time this program is invoked.
 *
 * @remark PGM T072B has the allow static storage re-initialization
 * attribute set to true and ACTGRP attribute set to AAA. See makefile
 * for details.
 */

/* static variable with initial value 5. */
int _i_static = 5;

int main(int argc, char *argv[]) {

  *(int*)argv[1] = _i_static++;
  return 0;
}
