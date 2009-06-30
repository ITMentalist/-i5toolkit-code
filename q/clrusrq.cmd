/** @file dspqd.cmd */

             CMD        PROMPT('Clear User Queue (CLRUSRQ)')

/* queue name */
             PARM       KWD(Q) TYPE(Q_NAME) MIN(1) KEYPARM(*YES) +
                          PROMPT('Queue object')

/* qualifiers */
 Q_NAME:     QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*CURLIB) (*LIBL)) PROMPT('Library +
                          name')

/* EOF */
