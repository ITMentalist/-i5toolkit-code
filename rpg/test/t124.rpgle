     /**
      * @file t124.rpgle
      *
      * Test of MATMIF.
      */
     h dftactgrp(*no)

      /copy mih54
     d basic_info      ds                  likeds(matmif_basic_tmpl_t)
     d prc_info        ds                  likeds(matmif_prc_tmpl_t)
     d len             s              5u 0

      /free
      /if not defined(*v5r2m0)
           len = %size(basic_info);
           dsply 'length of ds - 0001' '' len;

           basic_info.bytes_in = len;
           matmif(basic_info : x'0001');

           len = %size(prc_info);
           dsply 'length of ds - 0002' '' len;

           prc_info.bytes_in = len;
           matmif(prc_info : x'0002');

      /endif
           *inlr = *on;
      /end-free
