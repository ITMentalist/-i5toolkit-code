/**
 * @file h2c80.c
 *
 * read 80-byte input, write 160-byte hex-string output
 */

# include <stdlib.h>
# include <string.h>
# include <stdio.h>

# include <recio.h>
# include <mih/cvthc.h>

int main(int argc, char* argv[]) {

  char* fnam = NULL, *ofnam = NULL;
  _RFILE *fp = NULL, *ofp = NULL;
  _RIOFB_T* fb = NULL;
  char rec[80] = {0};
  char orec[160] = {0};

  if(argc < 3) {
    printf("Usage: call h2c80 hex-file char-file\x25");
    return -1;
  }
  fnam = argv[1];
  ofnam = argv[2];

  fp = _Ropen(fnam, "rr, rtncode=y");
  if(fp == NULL) return -1;
  if(fp->buf_length < 80) {
    _Rclose(fp);
    printf("Record length must be *GE 80.\x25");
    return -1;
  }
  ofp = _Ropen(ofnam, "wr", "rtncode=y");
  if(ofp == NULL) {
    _Rclose(fp);
    return -1;
  }

  fb = _Rreadf(fp, rec, 80, __DFT);
  while(fb->num_bytes == 80) {

    cvthc(orec,
          rec,
          160);
    _Rwrite(ofp, orec, 160);

    fb = _Rreadn(fp, rec, 80, __DFT);
  }

  _Rclose(fp);
  _Rclose(ofp);
  return 0;
}
