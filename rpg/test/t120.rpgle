     /**
      * @file t120.rpgle
      *
      * Test of _MATMATR1.
      */

     h dftactgrp(*no)

      /copy mih52
      * machine serial number
     d srlnbr          ds                  likeds(
     d                                       matmatr_machine_srlnbr_t)
     d opt             s              2a

      /free
           opt = x'0004';  // machine serial number
           matmatr(srlnbr : opt);
           srlnbr.bytes_in = %size(srlnbr);
           dsply 'machine serial number' '' srlnbr.srlnbr;

           *inlr = *on;
      /end-free
