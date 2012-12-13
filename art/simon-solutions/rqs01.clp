             /*******************************************************/
             /* @file ii265.clp                                     */
             /*******************************************************/
             DCL        VAR(&CMD) TYPE(*CHAR) LEN(1000)
             RCVMSG     MSGQ(BCHMCH) MSGTYPE(*ANY) WAIT(*MAX) +
                          RMV(*YES) MSG(&CMD)                             /* [1] */
             IF         COND(&CMD *EQ 'QUIT') THEN(GOTO CMDLBL(ENDPGM))   /* [2] */
             SNDPGMMSG  MSG(&CMD) TOPGMQ(*EXT) MSGTYPE(*RQS)              /* [3] */
             SNDPGMMSG  MSG('X II265') TOPGMQ(*EXT) MSGTYPE(*RQS)         /* [4] */
             RETURN                                                       /* [5] */
 ENDPGM:     SNDMSG     MSG('WU AH') TOMSGQ(*SYSOPR)
