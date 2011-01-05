     /**
      * @file t152.rpgle
      *
      * Test of _SETCA/_RETCA. Floating pointer calculation
      * under different rounding mode.
      *
      * @todo complete this test.
      */
     h dftactgrp(*no)

      /copy mih52
     d a               s              4f
     d b               s              4f   inz(3.0)
     d ca              s             10u 0

      /free
           a = 20;
           a /= b;
           a *= b; // A =   2.000000000000E+001

           ca = retca(x'01'); // retrieve round mode
           // set round mode to 'Round towards negative infinity'
           setca(x'0020' : 1);
           ca = retca(x'01');
           a = 20;
           a /= b;
           a *= b; // A =   1.999999809265E+001

           // set round mode to 'Round towards positive infinity'
           setca(0       : 1);
           ca = retca(x'01');
           a = 20;
           a /= b;
           a *= b; // A =   2.000000190735E+001

           *inlr = *on;
      /end-free
