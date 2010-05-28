/**
 * @file touch.c
 *
 * open/create a stream file with specified CCSID
 *
 * @param [in] path-name, null-terminated path name
 * @param [in] ccsid, bin(2)
 * @param [out] return value, bin(4), 0 if successful
 *
 * @return errno
 */

# include <stdlib.h>
# include <errno.h>
# include <fcntl.h>

int main(int argc, char *argv[]) {

  int fd = 0;
  short ccsid = 0;

  if(argc < 4)
    return -1;

  ccsid = *((short*)argv[2]);
  fd = open(argv[1],
            O_RDWR | O_CREAT | O_CCSID,
            S_IRUSR | S_IWUSR,
            ccsid);
  if(fd == -1) {
    *((int*)argv[3]) = errno;
    return errno;
  }

  close(fd);
  return 0;
}
