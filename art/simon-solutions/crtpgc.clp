/**                                                                 */
/** @file crtpgc.clp                                                */
/** CPP of the CRTPG command                                        */
/**                                                                 */
/** ART-ID: MATCRTPG                                                */
/**                                                                 */

  CRTPGC:     PGM        PARM(&QUALPGM &QUALFILE &MBR)

 /*                                                                 */
 /*----------------- Input Parameter Declarations ------------------*/
 /*                                                                 */
              DCL        VAR(&QUALPGM) TYPE(*CHAR) LEN(20)
              /* NameLibrary */
              DCL        VAR(&QUALFILE) TYPE(*CHAR) LEN(20)
              /* NameLibrary */
              DCL        VAR(&MBR) TYPE(*CHAR) LEN(10)
              /* Work file member */

 /*                                                                 */
 /*-------------------- Program Declarations -----------------------*/
 /*                                                                 */
              DCL        VAR(&PGM) TYPE(*CHAR) LEN(10)
              DCL        VAR(&PLIB) TYPE(*CHAR) LEN(10)
              DCL        VAR(&FILE) TYPE(*CHAR) LEN(10)
              /* Program template work file */
              DCL        VAR(&FLIB) TYPE(*CHAR) LEN(10)
              /* Work file library */
              DCL        VAR(&REALLIB) TYPE(*CHAR) LEN(10) /* Actual +
                           library containing file (for *LIBL +
                           search) */
             DCL        VAR(&MSGTYPE) TYPE(*CHAR) LEN(5)

             DCLF       FILE(QADSPOBJ)

/*                                                                 */
/*----------------- Mnemonic Value Declarations -------------------*/
/*                                                                 */
             DCL        VAR(&BLANK) TYPE(*CHAR) LEN(1) VALUE(X'40')
                       /* Mnemonic for 'blank' */
             DCL        VAR(&TRUE) TYPE(*LGL) LEN(1) VALUE('1')
                       /* Mnemonic for 'true' */
             DCL        VAR(&FALSE) TYPE(*LGL) LEN(1) VALUE('0')
                       /* Mnemonic for 'false' */
             DCL        VAR(&ERROR) TYPE(*LGL) LEN(1)
                       /* Mnemonic for 'error' */

/*                                                                 */
/*-------------- Global Message Monithr Declarations --------------*/
 /*                                                                 */
              DCL        VAR(&MSGDTA) TYPE(*CHAR) LEN(40)
              DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
              DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10)
              DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10)

 /*                                                                 */
 /*--------------- Global Message Monitor Intercept ----------------*/
 /*                                                                 */
              MONMSG     MSGID(CPF0000 MCH0000) EXEC(GOTO CMDLBL(ERROR))

 /* Substring out the program and library names */
              CHGVAR     VAR(&PGM) VALUE(%SST(&QUALPGM 1 10))
              CHGVAR     VAR(&PLIB) VALUE(%SST(&QUALPGM 11 10))
              CHGVAR     VAR(&FILE) VALUE(%SST(&QUALFILE 1 10))
              CHGVAR     VAR(&FLIB) VALUE(%SST(&QUALFILE 11 10))
              CHGVAR     VAR(&REALLIB) VALUE(&FLIB)

 /* Handle special values from command definition */
              IF         COND(&MBR *EQ '*PGM') THEN(DO)
                CHGVAR     VAR(&MBR) VALUE(&PGM)
              ENDDO
              IF         COND(&MBR *EQ '*FILE') THEN(DO)
                CHGVAR     VAR(&MBR) VALUE(&FILE)
             ENDDO

/* ********************************************************** */
/* If '*LIBL' was passed in for library, get the name of the  */
/* actual library containing the file.                        */
/*                                                            */
/* The trick to determining the library of an existing object */
/* is as follows:                                             */
/*                                                            */
/*  1. Rename the object to itself                            */
/*  2. CPF returns a message informing that the object was    */
/*      not renamed.                                          */
/*     On the AS/400, an escape message is sent.              */
/*     On the S/38, an informational message is sent          */
/*     This code section works on either machine.             */
/*  3. The library of the object is in positions 11 - 20      */
/*      of the message data associated with the message.      */
/* ********************************************************** */
             IF         COND(&REALLIB *EQ '*LIBL') THEN(DO)
               CHGVAR     VAR(&MSGTYPE) VALUE('*INFO')
               RNMOBJ     OBJ(&FILE) OBJTYPE(*FILE) NEWOBJ(&FILE)
               MONMSG     MSGID(CPF2132) EXEC(DO)
                 CHGVAR     VAR(&MSGTYPE) VALUE('*EXCP')
               ENDDO

               RCVMSG     MSGTYPE(&MSGTYPE) MSGDTA(&MSGDTA) MSGID(&MSGID)
               CHGVAR     VAR(&REALLIB) VALUE(%SST(&MSGDTA 11 10))
             ENDDO      /* RealLib */

/* Allocate the program */
             ALCOBJ     OBJ((&PLIB/&PGM *PGM *EXCL))
             MONMSG     MSGID(CPF1085) EXEC(DO)
               RCVMSG     MSGTYPE(*EXCP)
               GOTO       CMDLBL(CREATE) /* Not found */
             ENDDO

/* Ensure work file and member exist */
             CHKOBJ     OBJ(&REALLIB/&FILE) OBJTYPE(*FILE) MBR(&MBR)

/* Find out the current owner of the object */
             DSPOBJD    OBJ(&PLIB/&PGM) OBJTYPE(*PGM) +
                          DETAIL(*SERVICE) OUTPUT(*OUTFILE) +
                          OUTFILE(QTEMP/@RTVPGMOWN)

             OVRDBF     FILE(QADSPOBJ) TOFILE(QTEMP/@RTVPGMOWN)
             RCVF

/* Delete the existing program */
             DLTPGM     PGM(&PLIB/&PGM)

/* ************************************************************ */
/* Call the CPF module to recreate the program from the update  */
/* program template.                                            */
/* Note:- this interface is not supported after V2R1.1.         */
/* ************************************************************ */
 CREATE:     CALL       PGM(QSCCRTPG) PARM(&PGM &PLIB &FILE +
                          &REALLIB &MBR)

/* Ensure the original owner still owns the program */
/* Note:- Need to adopt GOD to ensure this works    */
             IF         COND(&ODOBOW *NE &BLANK) THEN(DO)
               CHGOBJOWN  OBJ(&REALLIB/&PGM) OBJTYPE(*PGM) +
                            NEWOWN(&ODOBOW)
             ENDDO

/*                                                                 */
/*--------------------- Send User a Message -----------------------*/
/*                                                                 */
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) +
                          MSGDTA('Program' *BCAT &PGM *BCAT 'in' +
                          *BCAT &REALLIB *BCAT 'created from +
                          member' *BCAT &MBR *BCAT 'in file' *BCAT +
                          &FILE *BCAT 'in' *BCAT &FLIB) MSGTYPE(*COMP)

 EXIT:       RETURN     /* Normal end of program */

 ERROR:      RCVMSG     MSGTYPE(*EXCP) MSGDTA(&MSGDTA) MSGID(&MSGID) +
                          MSGF(&MSGF) MSGFLIB(&MSGFLIB)
             MONMSG     MSGID(CPF0000 MCH0000) EXEC(RETURN)
                        /* Just in case */
             IF         COND(&MSGID *NE &BLANK) THEN(DO)
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*ESCAPE)
             MONMSG     MSGID(CPF0000 MCH0000) EXEC(RETURN)
                        /* Just in case */
             ENDDO

 CRTPGX:     ENDPGM
