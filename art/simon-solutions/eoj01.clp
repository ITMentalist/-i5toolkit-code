             DCL        VAR(&CNTRLD) TYPE(*CHAR) LEN(1)
             RTVJOBA    ENDSTS(&CNTRLD)
             SNDPGMMSG  MSG('Controlled Cancel' *BCAT &CNTRLD)
