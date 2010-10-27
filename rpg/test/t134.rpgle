     /**
      * @file t134.rpgle
      *
      * Test of TESTPDC.
      */

     h dftactgrp(*no)

      /copy mih52
     d r               s             10i 0

      /free
           r = testpdc();
           dsply 'PDC status' '' r;

           *inlr = *on;
      /end-free
