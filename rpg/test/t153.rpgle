     /**
      * @file t153.rpgle
      *
      * Test of _SETCA/_RETCA.
      * Suppress floating-point exceptions.
      */
     h dftactgrp(*no)

      /copy mih52
     d a               s              4f   inz(7.5)
     d b               s              4f   inz(3.0)
     d ca              s             10u 0

      /free
           // [1] retrieve current flt exception masks, occurances, and rounding mode
           ca = retca(x'0B'); // b'00001011'
             // ca = x'3A000460'
             // byte 0 (flt exception masks) = 3A, all flt-point exceptions except INEXACT-RESULT are enabled
             // byte 2 (occurances)          = 04, Floating-point inexact result
             // byte 3 (rounding mode)       = 60, bits 1-2 = 11 (round to nearest)

           // [2] clear flt-exception occurance byte
           setca(0 : x'02');
           ca = retca(x'0B');
             // ca = x'3A000060'

           // [3] suppress divided-by-zero exception
           setca(0 : x'08');
           b -= 3.0;
           a /= b;  // a = x'7F800000'

           // [4] retrieve flt exception occurances
           ca = retca(x'02');
             // ca = x'00000800'
             // byte 2 (occurances)          = 08, Floating-point zero divide

           setca(0 : x'02'); // clear flt-exception occurance byte
           b = 2;
           b **= 5;
           b **= 64;
           ca = retca(x'02');
             // ca = 00002400
             // byte 2 (occurances)          = 24, Floating-point overflow
             //                                    Floating-point inexact result

           *inlr = *on;
      /end-free
