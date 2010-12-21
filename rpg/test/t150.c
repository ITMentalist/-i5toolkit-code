/**
 * @file t150.c
 *
 * @todo introduction ...
 * @todo t150.rpgleinc
 */

# include <stdlib.h>
# include <string.h>

unsigned short cvt_bits2 ( char *src,
                           unsigned bytes,
                           unsigned offset,
                           unsigned len
                           ) {

  unsigned short r = 0;

  if(bytes > 2 || (offset + len) > 16)
    return (unsigned short)-1;

  memcpy(&r, src, bytes);
  r <<= offset;
  r >>= 16 - len;

  return r;
}

/**
 * @fn cvt_bits4
 *
 * @return unsigned bin(4)
 */
unsigned int cvt_bits4 ( char *src,
                         unsigned bytes,
                         unsigned offset,
                         unsigned len
                         ) {

  unsigned int r = 0;

  if(bytes > 4 || (offset + len) > 32)
    return (unsigned)-1;

  memcpy(&r, src, bytes);
  r <<= offset;
  r >>= 32 - len;

  return r;
}
