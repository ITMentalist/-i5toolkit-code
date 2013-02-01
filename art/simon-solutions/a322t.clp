             PGM        PARM(&PGNAM)
             DCL        VAR(&PGNAM) TYPE(*CHAR) LEN(10)
             DCL        VAR(&P1) TYPE(*PTR)
             DCL        VAR(&P2) TYPE(*PTR)
             DCL        VAR(&RE) TYPE(*CHAR) LEN(2)
             DCL        VAR(&A) TYPE(*CHAR) LEN(1)
             DCL        VAR(&B) TYPE(*CHAR) LEN(1)

 T1:         SNDPGMMSG  MSG('Test 1: 2 null pointers passed')
             CALL       PGM(&PGNAM) PARM(&P1 &P2 &RE)
             SNDPGMMSG  MSG('Comparison result: *' *CAT &RE)
 T2:         SNDPGMMSG  MSG('Test 2: 1 null pointer and 1 valid SPP +
                          passed')
             CHGVAR     VAR(&P2) VALUE(%ADDR(&A))
             CALL       PGM(&PGNAM) PARM(&P1 &P2 &RE)
             SNDPGMMSG  MSG('Comparison result: *' *CAT &RE)
 T3:         SNDPGMMSG  MSG('Test 3: 2 valid SPP with the same +
                          addressibility passed')
             CHGVAR     VAR(&P1) VALUE(%ADDR(&A))
             CALL       PGM(&PGNAM) PARM(&P1 &P2 &RE)
             SNDPGMMSG  MSG('Comparison result: *' *CAT &RE)
 TN:         SNDPGMMSG  MSG('Test n: two valid SPP with different +
                          addessibilities passed')
             CHGVAR     VAR(&P2) VALUE(%ADDR(&B))
             CALL       PGM(&PGNAM) PARM(&P1 &P2 &RE)
             SNDPGMMSG  MSG('Comparison result: *' *CAT &RE)
 ENDWHAT:    ENDPGM
