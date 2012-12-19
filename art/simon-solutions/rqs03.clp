             /*************************************************************/
             /* @file rqs03.clp                                           */
             /* Example request processor that supports CL and SQL.       */
             /*************************************************************/
             DCL        VAR(&MK) TYPE(*CHAR) LEN(4)
             DCL        VAR(&LEN) TYPE(*DEC) LEN(5 0)
             DCL        VAR(&SQLSTMT) TYPE(*CHAR) LEN(256)

             DCL        VAR(&CPOP) TYPE(*CHAR) LEN(20) +
                          VALUE(X'00000000F1F2F0000000000000000000000+
                          00000')
             DCL        VAR(&PRCTYP) TYPE(*INT) STG(*DEFINED) LEN(4) +
                          DEFVAR(&CPOP 1) /* Command process type. +
                          0 = run command directly */
             DCL        VAR(&DBCSOPT) TYPE(*CHAR) STG(*DEFINED) +
                          LEN(1) DEFVAR(&CPOP 5) /* DBCS data +
                          handling. '1' = handle DBCS data */
             DCL        VAR(&PMTOPT) TYPE(*CHAR) STG(*DEFINED) +
                          LEN(1) DEFVAR(&CPOP 6) /* Prompter action. */
             DCL        VAR(&CMDSNX) TYPE(*CHAR) STG(*DEFINED) +
                          LEN(1) DEFVAR(&CPOP 7) /* Command string +
                          syntax. '0' = using system syntax +
                          (instead of S/38 syntax) */
             DCL        VAR(&RQSMSGKEY) TYPE(*CHAR) STG(*DEFINED) +
                          LEN(4) DEFVAR(&CPOP 8) /* Message +
                          retrieve key identifing a request message. */
             DCL        VAR(&CMDCCSID) TYPE(*INT) STG(*DEFINED) +
                          LEN(4) DEFVAR(&CPOP 12) /* CCSID of +
                          command string. 0 = use job CCSID */
             DCL        VAR(&CPOPRSVD) TYPE(*CHAR) STG(*DEFINED) +
                          LEN(5) DEFVAR(&CPOP 16)

             DCL        VAR(&QUSEC) TYPE(*CHAR) LEN(16) +
                          VALUE(X'00000000000000000000000000000000')
             DCL        VAR(&CMDSTR) TYPE(*CHAR) LEN(256)
             DCL        VAR(&CMDSTRLEN) TYPE(*INT) LEN(4) VALUE(2)
             DCL        VAR(&CPOPLEN) TYPE(*INT) LEN(4) VALUE(20)
             DCL        VAR(&CPOPFMT) TYPE(*CHAR) LEN(8) +
                          VALUE('CPOP0100')
             DCL        VAR(&CMDRTN) TYPE(*CHAR) LEN(256)
             DCL        VAR(&CMDRTNLEN) TYPE(*INT) LEN(4) VALUE(256)
             DCL        VAR(&CMDRRLEN) TYPE(*INT) LEN(4)

             MONMSG     MSGID(CPF1907 CPF2415) EXEC(GOTO +
                          CMDLBL(QUIT)) /* CPF1907=End reqeust, +
                          CPF2415=F3 or F12. Time to quit */
/* 1) Receive a *RQS message from message queue *EXT */
 READ:       RCVMSG     PGMQ(*EXT) MSGTYPE(*RQS) RMV(*NO) +
                          KEYVAR(&MK) MSG(&CMDSTR) MSGLEN(&LEN)
/* 2) Process a request */
             IF         COND(%SST(&CMDSTR 1 1) *EQ '%') THEN(DO)
                 CHGVAR %SST(&CMDSTR 1 1) ' '
                 CHGVAR     VAR(&SQLSTMT) VALUE('db2 "' *CAT &CMDSTR +
                              *TCAT '"')
                 SBMJOB     CMD(STRQSH CMD(&SQLSTMT)) JOB(PRC_SQL)
             ENDDO      /* END OF SQL PROCESSING */
             ELSE       CMD(DO)
                 CHGVAR     VAR(&RQSMSGKEY) VALUE(&MK)
                 CHGVAR     VAR(&CMDSTRLEN) VALUE(&LEN)
                 CALL       PGM(QCAPCMD) PARM(&CMDSTR &CMDSTRLEN &CPOP +
                              &CPOPLEN &CPOPFMT &CMDRTN &CMDRTNLEN +
                              &CMDRRLEN &QUSEC)
                 MONMSG     MSGID(CPF9901) EXEC(RCLRSC) /* Request check */
                 MONMSG     MSGID(CPF9999) EXEC(RCLRSC) /* Function +
                              check */
             ENDDO      /* END OF CL PROCESSING */

             GOTO       CMDLBL(READ)
/* 3) Clean-up */
 QUIT:       RMVMSG     PGMQ(*SAME (*)) CLEAR(*ALL)
             SNDPGMMSG  MSG('Farewell :p')
 BANG:       ENDPGM
