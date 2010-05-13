     /**
      * @file t073.rpgle
      *
      * test _SYNCSTG
      */
     h dftactgrp(*no)

      /copy mih54
     d a               s             10i 0 inz(7)

      /free
      /if defined(*v5r4m0)
           syncstg(0);
      /endif
           *inlr = *on;
      /end-free
