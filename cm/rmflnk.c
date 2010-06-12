/**
 * @file rmflnk.c
 */

# include <stdlib.h>
# include <stdio.h>
# include <string.h>

# include <unistd.h>
# include <sys/stat.h>

# ifndef __OS400__
#  error "This utility is supposed to be use in i5/OS QShell or PASE environment only."
# endif

int main(int argc, char *argv[]) {

  int len = 0;
  char *buf = NULL;
  int i = 0;
  char *cmd = NULL;
  int lnk_removed = 0;
  struct stat f_info;

  if(argc < 2)
    return 1;

  for(i = 1; i < argc; i++) {

    lnk_removed = 0;

    // -e
    if(stat(argv[i], &f_info) != 0)
      continue;

    // read link info
    len = readlink(argv[i], NULL, 0);
    if(len == -1) { // not a *SYMLNK
      // remove the input link
      unlink(argv[i]);
      lnk_removed = 1;
      continue;
    }

    buf = malloc(len + 1);
    memset(buf, 0, len + 1);
    len = readlink(argv[i], buf, len);

    // remove link target
    stat(buf, &f_info);
    cmd = malloc(len + 30);
    if(       memcmp(f_info.st_objtype, "*FILE     ", 10) == 0) {
      sprintf(cmd, "strqsh cmd('rm -fr %s')", buf);
      system(cmd);
    } else if(memcmp(f_info.st_objtype, "*DIR      ", 10) == 0) {
      sprintf(cmd, "rmvdir '%s'", buf);
      system(cmd);
    } else
      unlink(buf);

    // remove the input link
    if(lnk_removed == 0)
      unlink(argv[i]);

    free(cmd);
    free(buf);
  }

  return 0;
}
