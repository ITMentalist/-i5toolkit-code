     /**
      * @file t126.rpgle
      *
      * Test of MATRMD.
      */

     h dftactgrp(*no)

      /copy mih52
     d prc_util        ds                  likeds(matrmd_tmpl01_t)
     d stg_cnt         ds                  likeds(matrmd_tmpl03_t)
     d msp             ds                  likeds(matrmd_tmpl04_t)
     d addr            ds                  likeds(matrmd_tmpl08_t)
     d opt             ds                  likeds(matrmd_option_t)
     d hours           s             20u 0

      /free

           // processor utilization
           prc_util = *allx'00';
           prc_util.bytes_in = %size(prc_util);
           opt = *allx'00';
           opt.val = x'01';
           matrmd(prc_util : opt);

           hours = prc_util.prc_time / sysclock_one_hour;
           dsply 'Processor time since IPL' '' hours;

           // storage management counters
           stg_cnt.bytes_in = %size(stg_cnt);
           opt.val = x'03';
           matrmd(stg_cnt : opt);

           // storage transient pool information
           msp.bytes_in = %size(msp);
           opt.val = x'04';
           matrmd(msp : opt);
           dsply 'MSP' '' msp.msp_num;

           // Machine Address Threshold Data
           addr.bytes_in = %size(addr);
           opt.val = x'08';
           matrmd(addr : opt);

           *inlr = *on;
      /end-free
