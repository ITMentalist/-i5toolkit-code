/**
 * @file crt-inx.cpp
 *
 * create EMI's builtin index
 *  - entry length = 256
 *  - key length = 5
 * 即，实际可以放statement text的长度为251 bytes
 */

# include <iostream>
# include <string>
using namespace std;

# ifdef __OS400__
# include <qusec.h>
# include <quscrtui.h>
# include <qusaddui.h>
# include <qusrtvui.h>
# endif // defined __OS400__

# include <builtin-fmt.hpp>

int main() {

  char text[] = {
    "EMI Builtins                                      "
  };

# ifdef __OS400__
  Qus_EC_t *ec = (Qus_EC_t*)malloc(256);
  memset(ec, 0, 256);

  memset(ec, 0, 256);
  ec->Bytes_Provided = 256;

  QUSCRTUI(
           _EMI_BUILTIN_INDEX,
           "EMIBUILITN",
           "F",
           _MIC_BUILTIN_INX_LEN,
           "1",
           7,
           "1",
           "0",
           "*EXCLUDE  ",
           text,
           "*YES      ",
           ec
           );
  if(ec->Bytes_Available != 0) {

    cout << "failed to create builtin index, exception id: "
         << string(ec->Exception_Id, 7) << endl;
    free(ec);
    return 1;
  }

  free(ec);
# endif // defined __OS400__

  return 0;
}
