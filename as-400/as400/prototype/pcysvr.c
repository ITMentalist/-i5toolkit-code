/**
 * This file is part of i5/OS Programmer's Toolkit.
 * 
 * Copyright (C) 2010, 2011  Junlei Li (李君磊).
 * 
 * i5/OS Programmer's Toolkit is free software: you can redistribute
 * it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * i5/OS Programmer's Toolkit is distributed in the hope that it will
 * be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with i5/OS Programmer's Toolkit.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

/**
 * @file pcysvr.c
 *
 * The policy file server.
 *
 * @remark for details of deploying a policy server on an IBM i
 * server, please refer to:
 * http://i5toolkit.sourceforge.net/as-400/page_policy_server.html
 */

# include <stdlib.h>
# include <stdio.h>
# include <string.h>

# include <sys/types.h>
# include <sys/socket.h>
# include <netinet/in.h>
# include <arpa/inet.h>

# include <sys/time.h>
# include <signal.h>

# define _PORT 55556

/**
 * Content of the example policy file. This policy file allow a Flash
 * client to connect to any ports or your IBM i server.
 */
# pragma convert(1208)
static const char *_policy =
  "<?xml version=\"1.0\"?>" \
  "<!DOCTYPE cross-domain-policy SYSTEM \"http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd\">" \
  "<cross-domain-policy>" \
  "<allow-access-from domain=\"*\" to-ports=\"*\" />" \
  "</cross-domain-policy>"
  ;
# pragma convert(0)

static unsigned _quit = 0;

void on_term(int p) {
  _quit += 1;
}

int reg_signal_h() {

  int r = 0;
  struct sigaction act;
  memset(&act, 0, sizeof(act));
  act.sa_handler = on_term;
  r = sigemptyset(&act.sa_mask);
  r = sigaction(SIGTERM, &act, NULL);

  return r;
}

int main(int argc, char *argv[]) {

  struct sockaddr_in addr;
  struct sockaddr_in client;
  fd_set rset;
  struct timeval timeout = {5, 0};
  int svr = 0, clnt = 0, maxfd = 0, r = 0, i = 0;
  int addr_len = sizeof client;
  int sock_opt = 1;

  svr = socket(PF_INET, SOCK_STREAM, 0);
  // reuse port
  r = setsockopt(svr, SOL_SOCKET, SO_REUSEADDR, (void*)&sock_opt, sizeof(sock_opt));
  r = setsockopt(svr, SOL_SOCKET, SO_LINGER, (void*)&sock_opt, sizeof(sock_opt));

  // bind
  memset(&addr, 0, sizeof addr);
  addr.sin_family = AF_INET;
  addr.sin_port   = htons(_PORT);
  addr.sin_addr.s_addr = INADDR_ANY;
  r = bind(svr, (struct sockaddr*)&addr, sizeof addr);

  // listen
  r = listen(svr, SOMAXCONN);

  // register handler for SIGTERM
  r = reg_signal_h();

  // select & accept
  maxfd = svr + 1;

  while(!_quit) {

    FD_ZERO(&rset);
    FD_SET(svr, &rset);
    timeout.tv_sec = 5;
    if(select(maxfd, &rset, NULL, NULL, &timeout) == -1) {
      printf("select() failed\n");
      break;
    }

    if(FD_ISSET(svr, &rset)) {

      printf("Incoming connection request accepted.\n");
      clnt = accept(svr, (struct sockaddr*)&client, &addr_len);

      // send policy file to ...
      r = send(clnt, (char*)_policy, strlen(_policy), 0);
      printf("Policy file sent (%d bytes)\n", r);

      r = close(clnt);
    }
  }

  close(svr);
  return 0;
}
