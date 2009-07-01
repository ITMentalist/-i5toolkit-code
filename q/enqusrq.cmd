/* file enqusrq.mi */
             CMD        PROMPT('Clear User Queue (CLRUSRQ)')

             PARM       KWD(Q) TYPE(Q_OBJ) MIN(1) PROMPT('Queue +
                          object') /* Parm1: queue object */
             PARM       KWD(KEY) TYPE(*CHAR) LEN(256) VARY(*YES +
                          *INT2) CASE(*MIXED) INLPMTLEN(50) +
                          PROMPT('Key data') /* Parm2: key data */
             PARM       KWD(MSG) TYPE(*CHAR) LEN(5000) VARY(*YES +
                          *INT2) CASE(*MIXED) INLPMTLEN(80) +
                          PROMPT('Message text') /* Parm3: message +
                          text */
             PARM       KWD(MSGLEN) TYPE(*DEC) LEN(5 0) +
                          PROMPT('Message Text Length')

 Q_OBJ:      QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*CURLIB) (*LIBL)) PROMPT('Library +
                          name')
