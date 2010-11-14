     /**
      * @file t141.rpgle
      *
      * Test of _MATPG.
      */
     h dftactgrp(*no)

      /copy mih52
     d rcv             ds                  likeds(matpg_tmpl_t)
     d                                     based(bufptr)
     d bufptr          s               *
     d len             s             10i 0
      * OPM MI program
     d spr37           s               *

      /free
           len = %size(rcv);
           dsply 'length of matpg_tmpl_t' '' len;

           rslvsp_tmpl.obj_type = x'0201';
           rslvsp_tmpl.obj_name = 'SPR37';
           rslvsp2(spr37 : rslvsp_tmpl);

           len = 8;
           bufptr = modasa(len);
           rcv.bytes_in = len;
           matpg(rcv : spr37);

           len = rcv.bytes_out;
           bufptr = modasa(len);
           rcv.bytes_in = len;
           matpg(rcv : spr37);
             // check rcv

           *inlr = *on;
      /end-free
