/**
 * @file callx.c
 *
 * Exports:
 *  - callxx()
 */

# include <stdlib.h>
# include <string.h>

# pragma linkage(_CALLPGMV, builtin)
void _CALLPGMV(void**, void**, unsigned);

/**
 * Call whoever!
 */
void callxx(void **pgm,
            void **argv,
            unsigned argc) {
  _CALLPGMV(pgm, argv, argc);
}
