/** @file dspqmsg.cmd */
/*  crtcmd cmd(*curlib/dspqmsg) pgm(*libl/qmsg) srcfile(...) srcmbr(...) */

             CMD        PROMPT('Display Queue Messages')

/* program name */
             PARM       KWD(Q) TYPE(Q_NAME) MIN(1) KEYPARM(*YES) +
                          PROMPT('Queue object')
             PARM       KWD(QTYPE) TYPE(*NAME) LEN(10) RSTD(*YES) +
                          DFT(*DTAQ) SPCVAL((*DTAQ) (*USRQ)) MIN(0) +
                          PROMPT('Queue type')

/* qualifiers */
 Q_NAME:     QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*CURLIB) (*LIBL)) PROMPT('Library +
                          name')

/* EOF */
