     /**
      * @file t147.rpgle
      *
      * Test of _MATMATR1. Materialized HMC info.
      */
     h dftactgrp(*no)

      /copy mih52
     d tmpl            ds                  likeds(matmatr_hmc_t)
     d                                     based(ptr)
     d ptr             s               *
     d len             s             10i 0
     d opt             s              2a   inz(x'0204')

      /free
           ptr = modasa(8);
           tmpl.bytes_in = 8;
           matmatr(tmpl : opt);

           len = tmpl.bytes_out;
           ptr = modasa(len);
           tmpl.bytes_in = len;
           matmatr(tmpl : opt);
             // check returned HMC info

           *inlr = *on;
      /end-free

     /**
      * The returned HMC info might like the following:
      * @code
      * > EVAL TMPL.HMC_INFO.INFO(1):x 100                
      *      00000     486D6353 7461743D 313B4873 634E616D
      *      00010     653D3730 34324352 342A3036 37344542
      *      00020     423B4873 63486F73 744E616D 653D6C6F
      *      00030     63616C68 6F73743B 48736349 50416464
      *      00040     723D3132 372E302E 302E313B 48736341
      *      00050     64644950 733D3B48 4D434164 64495076
      *      00060     36733D3B ........ ........ ........
      * @endcode
      *
      * Convert the above result into ASCII encoding, then the
      * result should like the following:
      * 'HmcStat=1;... ...'
      */
