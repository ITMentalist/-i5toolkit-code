             /** @file spc01.clp                                    */
             /** Example program used in the SPCTRK article         */
             /** Calls:  SPC02                                      */
             PGM        PARM(&SRCLIB &GPL)
             DCL        VAR(&SRCLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&GPL) TYPE(*CHAR) LEN(10)
             DCL        VAR(&FINDCMD) TYPE(*CHAR) LEN(80)
             DCL        VAR(&SPCNAM) TYPE(*CHAR) LEN(20)
             CHGVAR     VAR(&FINDCMD) VALUE('find /qsys.lib/' *CAT +
                          &SRCLIB *TCAT '.lib -type f -ctime -7 > +
                          /qsys.lib/' *CAT &GPL *TCAT +
                          '.lib/oneweek.usrspc')
             STRQSH     CMD(&FINDCMD) /* Run QShell find command */
             CHGVAR     VAR(&SPCNAM) VALUE('ONEWEEK   ' *CAT &GPL)
             CALL       PGM(SPC02) PARM(&SPCNAM) /* Parse the output +
                          of previous issued QShell find command */
             DSPSPLF    FILE(QSYSPRT) JOB(*) SPLNBR(*LAST) /* Show +
                          search result */
