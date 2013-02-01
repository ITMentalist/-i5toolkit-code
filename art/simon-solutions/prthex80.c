/**
 * @file prthex80.c
 *
 * print 80-column file in hex form. 8-byte a block.
 */

# include <stdlib.h>
# include <string.h>
# include <stdio.h>

# include <recio.h>
# include <mih/cvthc.h>

int main(int argc, char* argv[]) {

  char* fnam = NULL;
  _RFILE *fp = NULL, *ofp = NULL;
  _RIOFB_T* fb = NULL;
  char rec[80] = {0};
  char orec[132] = {0};
  char c32[32] = {0};
  int i = 0, flds = 1;
  unsigned off = 0;

  if(argc < 2) {
    printf("Usage: call prthex80 file-name\x25");
    return -1;
  }
  fnam = argv[1];

  fp = _Ropen(fnam, "rr, rtncode=y");
  if(fp == NULL) {
    return -1;
  }
  if(fp->buf_length < 80) {
    _Rclose(fp);
    printf("Record length must be *GE 80.\x25");
    return -1;
  }
  ofp = _Ropen("QSYSPRT", "wr", "rtncode=y");

  // header
  memset(orec, 0x40, 132);
  memcpy(orec, fnam, strlen(fnam));
  _Rwrite(ofp, orec, 132);

  memset(orec, 0x40, 132);
  flds = 1;
  off = 0;
  fb = _Rreadf(fp, rec, 80, __DFT);
  while(fb->num_bytes == 80) {

    for(i = 0; i < 10; i++, off+=8, flds+=1) {
      if((flds - 1)%4 == 0) {
        // offset field
        cvthc(orec + 1,
              (const char*)&off,
              8);
      }

      cvthc(orec + 13 + (flds-1) * 17,
            rec + i * 8,
            16);
      memcpy(c32 + (flds - 1) * 8,
             rec + i * 8,
             8); // Save 8-byte into c32

      if(flds%4 == 0) { // One line completed
        // char form 32-byte
        orec[81] = '*';
        orec[82 + 32] = '*';
        memcpy(orec + 82, c32, 32);
        _Rwrite(ofp, orec, 132);
        flds -= 4;
        memset(orec, 0x40, 132);
      }
    }

    fb = _Rreadn(fp, rec, 80, __DFT);
  }

  _Rclose(fp);
  _Rclose(ofp);
  return 0;
}
