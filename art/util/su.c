/**
 * @file su1.c
 *
 * C version of the CPP of the SU command.
 */

# include <stdlib.h>
# include <string.h>
/// @remark Don't forget to include exception class definitions!
# include <except.h>
# include <decimal.h>

# include <qsygetph.h>
# include <qsnddtaq.h>
# include <qwtsetp.h>
# include <qsyrlsph.h>
# include <qrcvdtaq.h>
# include <qmhsndpm.h>

# define _SUDTAQ_NAME "@SUDTAQ   "
# define _SUDTAQ_LIB  "QTEMP     "
# define _MAX_PWD_LEN 128

# pragma linkage(_RSLVSP4, builtin)
void _RSLVSP4(void **pobjptr,
              void *resolve_template,
              void ** ctx);

# pragma linkage(_PCOPTR2, builtin)
void* _PCOPTR2(void);

typedef _Packed struct {
  void *sept_spp;
  void *wcbt;
  void *dmcq;
  void *devd;
  void *qtemp;
} pco_t;

void swap_to(char *usr, char *pwd);
void swap_back();

int main(int argc, char* argv[]) {

  char *usr = NULL;
  char *pwd = NULL;

  if(argc < 3) {
    // Ooops
    return -1;
  }
  usr = argv[1];
  pwd = argv[2];

  if(memcmp(usr, "*EXIT", 5) != 0)
    swap_to(usr, pwd);
  else
    swap_back();

  return 0;
}

void swap_to(char *usr, char *pwd) {

  int r = 1;
  pco_t *pco = NULL;
  void *q = NULL;
  char rt[34] = {0};
  char org_ph[12] = {0};
  char tgt_ph[12] = {0};
  decimal(5,0) ent_len = 12d;
  char ec[16] = {0};
  int pwd_len = 0;
  char *where = 0;

  pco = _PCOPTR2();

  memcpy(rt, "\xa\x1", 2);
  memset(rt + 2, 0x40, 30);
  memcpy(rt + 2,
         "@SUDTAQ   ",
         10);
# pragma exception_handler(oops, 0, 0, _C2_MH_ESCAPE)
  _RSLVSP4(&q, rt, &pco->qtemp);
# pragam disable_handler
  r = 0;
 oops:
  if(r) // Create *DTAQ QTEMP/@SUDTAQ
    system("CRTDTAQ DTAQ(QTEMP/@SUDTAQ) MAXLEN(12) " \
           "SEQ(*LIFO) AUT(*CHANGE)");

  // Save current PH
  QSYGETPH("*CURRENT  ", "", org_ph);
  QSNDDTAQ(_SUDTAQ_NAME, _SUDTAQ_LIB, ent_len, org_ph);

  // Switch to target USRPRF
  if(memcmp(pwd, "*NOPWD", 6) == 0)
    QSYGETPH(usr, pwd, tgt_ph);  // pwd is one of the *NOPWD### special values
  else {
    // Calculate password length
    pwd_len = _MAX_PWD_LEN;
    where = memchr(pwd, 0x40, _MAX_PWD_LEN);
    if(where != NULL)
      pwd_len = (char*)where - pwd;
    QSYGETPH(usr, pwd, tgt_ph, ec, pwd_len, -1);
  }
  QWTSETP(tgt_ph);
  QSYRLSPH(tgt_ph);
}

void swap_back() {

  char org_ph[12] = {0};
  decimal(5,0) ent_len = 12d;
  decimal(5,0) timeout = 0d;
  char mk[4] = {0};
  char ec[16] = {0};

  // Retrieve previous PH
  QRCVDTAQ(_SUDTAQ_NAME, _SUDTAQ_LIB, &ent_len, org_ph, timeout);
  if(ent_len == 0d) {
    QMHSNDPM("CPF9898",
             "QCPFMSG   QSYS      ",
             "Exit to where? :p",
             17,
             "*ESCAPE   ",
             "*PGMBDY   ",
             1,
             mk,
             ec);
    return;
  }

  // Switch back to previsou USRPRF
  QWTSETP(org_ph);
  QSYRLSPH(org_ph);
}
