             /**                                                    */
             /** @file a322.clp                                     */
             /**                                                    */
             PGM        PARM(&P1 &P2 &RE)
             DCL        VAR(&P1) TYPE(*PTR)
             DCL        VAR(&P2) TYPE(*PTR)
             DCL        VAR(&RE) TYPE(*CHAR) LEN(2)
             DCL        VAR(&IN1) TYPE(*CHAR) LEN(1) VALUE('0')
               /* '1'=&P1 is a null pointer, '0'=&P1 is NOT null */
             DCL        VAR(&IN2) TYPE(*CHAR) LEN(1) VALUE('0')
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(1)
             DCL        VAR(&B) TYPE(*INT) LEN(4)

             CHGVAR     VAR(&RE) VALUE('EQ')
 TCHOPT:     CHGVAR     VAR(&OPT) VALUE(X'00')
             IF         COND(&B *GT 78) THEN(GOTO CMDLBL(LALA))

 LALA:       IF         COND((&IN1 *EQ '1') *AND (&IN2 *EQ '1')) +
                          THEN(GOTO CMDLBL(ENDCMP))
               /* Both pointers are null pointers. So they are EQ */
             IF         COND(&IN1 *NE &IN2) THEN(DO)
               /* One of the two pointers is null pointer */
               CHGVAR VAR(&RE) VALUE('NE')
               GOTO ENDCMP
             ENDDO
             IF         COND(&P1 *NE &P2) THEN(CHGVAR VAR(&RE) +
                          VALUE('NE'))
               /* Since neither is null pointer, compare +
                          their addressibilities. */

 ENDCMP:     ENDPGM
