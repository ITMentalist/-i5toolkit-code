/**
 * @file miobjtype.c
 *
 * convert external object type to mi object type
 */

# include <stdlib.h>
# include <stdio.h>
# include <string.h>
# include <ctype.h>

# include <qusec.h>
# include <qlicvttp.h>

# define NEW_LINE "\x25"
# define ECLEN        32

# define _usage "Usage info: convert external object type to " \
  "MI (Machine Interface) object type." NEW_LINE               \
  "    miobjtype mi-obj-type" NEW_LINE                         \
  " - mi-obj-type, MI (Machine Interface) object type, such "  \
  "*FILE, *USRIDX, *USRQ" NEW_LINE                             \
  NEW_LINE                                                     \
  "e.g. miobjtype *USRIDX" NEW_LINE

static char *_err_info[8] = {
  "CPF2101 Object type *&1 not valid.",
  "CPF2102 Object type and subtype code &1 not valid.",
  "CPF219C Conversion value &1 not valid.",
  "CPF219D Object type &1 not valid external object type.",
  "CPF24B4 Severe error while addressing parameter list.",
  "CPF3C90 Literal value cannot be changed.",
  "CPF3CF1 Error code parameter not valid.",
  "Unknown error."
};

char *map_cvttp_error(const char *exid);

int main(int argc, char *argv[]) {

  char ecb[ECLEN] = {0};
  char ex_type[10] = {"          "};
  char mi_type[2] = {0};
  int i = 0;
  size_t len = 0;
  Qus_EC_t *ec = (Qus_EC_t*)ecb;

  if(argc < 2) {

    printf(_usage NEW_LINE);
    return 1;
  }

  len = strlen(argv[1]);
  len = (len <= 10) ? len : 10;
  memcpy(ex_type, argv[1], len);
  for(; i < 10; i++)
    ex_type[i] = toupper(ex_type[i]);

  ec->Bytes_Provided = ECLEN;
  QLICVTTP(
           "*SYMTOHEX ",
           ex_type,
           mi_type,
           ec
           );
  if(ec->Bytes_Available != 0) {

    printf("%s" NEW_LINE,
           map_cvttp_error(ec->Exception_Id));
    return 1;
  }

  printf("MI object type: %02X%02X" NEW_LINE,
         mi_type[0],
         mi_type[1]
         );
  return 0;
}

/**
 * map exception ID of QLICVTTP to error message
 */
char *
map_cvttp_error(
                const char *exid
                ) {

  int i = 0;
  char *rtn = _err_info[7];

  for(; i < 7; i++) {

    if(memcmp(_err_info[i], exid, 7) == 0) {

      rtn = _err_info[i] + 8;
      break;
    }
  }

  return rtn;
}
