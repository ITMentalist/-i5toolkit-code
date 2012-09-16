             PGM        PARM(&MSG)
             DCL        VAR(&MSG) TYPE(*CHAR) LEN(20)
             SNDMSG     MSG(&MSG) TOMSGQ(*SYSOPR)
