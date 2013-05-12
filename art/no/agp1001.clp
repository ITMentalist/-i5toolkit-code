             DCL        VAR(&NUM) TYPE(*INT) LEN(4) VALUE(0)
             DCL        VAR(&AGPMRK) TYPE(*CHAR) LEN(8)
 LOOP:       IF         COND(&NUM *GE 1001) THEN(GOTO CMDLBL(ENDLOOP))
             CALL       PGM(STRUAG) PARM(&AGPMRK)
             CHGVAR     VAR(&NUM) VALUE(&NUM + 1)
             GOTO       CMDLBL(LOOP)
 ENDLOOP:    ENDPGM
