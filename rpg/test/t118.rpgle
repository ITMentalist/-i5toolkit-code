     /**
      * @file t118.rpgle
      *
      * This program shows how to reinitialize static storage of an OPM
      * program via MI instruction ACTPG.
      *
      * @remark T118A is an OPM MI program that uses a static Bin(2) scalar.
      *         val. Initial value of val is 7. T118A increase val's value
      *         by 1 each time it is invoked.
      */

     h dftactgrp(*no)

      /copy mih52

      * system pointer to T118A
     d opm_pgm         s               *
     d ssf             ds                  qualified
     d                                     based(ssf_ptr)
     d   header                      64a
     d   val                          5i 0
     d ssf_ptr         s               *
      * prototype of T118A
     d t118a           pr                  extpgm('T118A')

      /free
           // activate OPM MI program T118A
           rslvsp_tmpl.obj_type = x'0201';
           rslvsp_tmpl.obj_name = 'T118A';
           rslvsp2(opm_pgm : rslvsp_tmpl);
           actpg(ssf_ptr : opm_pgm);
           dsply 'Static variable VAL' '' ssf.val;
             // val = 7

           // call T118A
           t118a();

           // check val's value
           dsply 'Static variable VAL' '' ssf.val;
             // val = 8

           // reactivate T118A to reset static variable val
           actpg(ssf_ptr : opm_pgm);

           // check val's value
           dsply 'Static variable VAL' '' ssf.val;
             // val = 7

           *inlr = *on;
      /end-free
