/**
 * @file mtime.c
 *
 * Returns the last modification time of an IFS object in form of
 * time_t.  Usage: call mtime parm('/ifs/object/path/name'
 * last-modification-time)
 *
 * @remark the last modification-time param is in form of time_t, aka
 * 4-byte binary.
 */

# include <stdlib.h>
# include <sys/stat.h>

int main(int argc, char *argv[]) {

  int r = 0;
  struct stat f_info;

  if(argc < 3)
    return 1;

  r = stat(argv[1], &f_info);
  if(r == 0)
    *((int*)argv[2]) = f_info.st_mtime;
  else
    *((int*)argv[2]) = 0;

  return r;
}
