/**
 * @file rlink.c
 *
 * Neighter QShell nor PASE does not have a readlink utility.
 * This utility is designed to be a QShell version readlink.
 * When working in PASE environment, you can utilize this
 * utitlity by using pase command qsh or qsh_out. For example
 * qsh_ouit -c "readlink some-symbolic-link".
 *
 * You may test this utility by the following steps:
 *  - In QShell, type: ln -s /qsys.lib/somelib.lib/rlink.pgm /usr/bin/readlink
 *  - In QShell, type readlink /usr/bin/readlink
 */

# include <stdlib.h>
# include <stdio.h>
# include <unistd.h>

# ifndef __OS400__
#  error "This utility is supposed to be use in i5/OS QShell or PASE environment only."
# endif

int main(int argc, char *argv[]) {

  int len = 0;
  char *buf = NULL;

  if(argc < 2 ||\
     (len = readlink(argv[1], NULL, 0)) < 0) {
    printf("\x25");
    return 1;
  }

  buf = malloc(len + 1);
  buf[len] = 0;
  len = readlink(argv[1], buf, len);

  printf("%s\x25", buf);
  return 0;
}
