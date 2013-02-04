/**
 * @file c2h80.c
 *
 * read 80-byte input, write 160-byte hex-string output
 */

# include <stdlib.h>
# include <string.h>
# include <stdio.h>

# include <recio.h>
# include <mih/cvtch.h>

int main(int argc, char* argv[]) {

  char* fnam = NULL, *ofnam = NULL;
  _RFILE *fp = NULL, *ofp = NULL;
  _RIOFB_T* fb = NULL;
  char rec[160] = {0};
  char orec[80] = {0};

  if(argc < 3) {
    printf("Usage: call c2h80 char-file hex-file\x25");
    return -1;
  }
  fnam = argv[1];
  ofnam = argv[2];

  fp = _Ropen(fnam, "rr, rtncode=y");
  if(fp == NULL) return -1;
  if(fp->buf_length < 160) {
    _Rclose(fp);
    printf("Record length must be *GE 160.\x25");
    return -1;
  }
  ofp = _Ropen(ofnam, "wr", "rtncode=y");
  if(ofp == NULL) {
    _Rclose(fp);
    return -1;
  }

  fb = _Rreadf(fp, rec, 160, __DFT);
  while(fb->num_bytes == 160) {

    cvtch(orec,
          rec,
          160);
    _Rwrite(ofp, orec, 80);

    fb = _Rreadn(fp, rec, 160, __DFT);
  }

  _Rclose(fp);
  _Rclose(ofp);
  return 0;
}
