     /**
      * @file wcbt2.rpgle
      *
      * Simulate the process of retrieving the system pointer to
      * the PCS object associated with an MI process.
      */

     h dftactgrp(*no) actgrp('WCBT2')

      * Prototype of this program
     d me              pr                  extpgm('WCBT2')
     d   jobnam                      10a
     d   jobusr                      10a
     d   jobnum                       6a
     d   pcs@                          *
      * Prototye of system built-in Return PCO Pointer (PCOPTR2)
     d pcoptr2         pr              *   extproc('_PCOPTR2')
      * Prototye of system built-in Set Space Pointer from Pointer (SETSPPFP)
     d setsppfp        pr              *   extproc('_SETSPPFP')
     d   src_ptr                       *   value procptr
      * Prototype of system built-in Find Independent Index Entry (FNDINXEN)
     d fndinxen        pr                  extproc('_FNDINXEN')
     d     receiver                   1a   options(*varsize)
     d     index                       *
     d     opt_list                   1a   options(*varsize)
     d     argument                   1a   options(*varsize)

     d pco             ds                  based(pco@)
     d                              432a
      * SYP to QWCBT00 at offset hex 1B0 in the PCO
     d   syp_qwcbt00@                  *   procptr
     d roo_wcbt        ds                  based(wcbt@)
     d                              544a
      * SYP to the job index at offset hex 220 in
      * the associated space of QWCBT00
     d   job_inx@                      *
      * Operand 1 of FNDINXEN, receiver
     d rcv             ds
     d   rcv_arg                     32a
     d   wcbte@                        *
      * Operand 3 of FNDINXEN, option list
     d opt_lst         ds
      * Rule option, x'0001' = search for EQUAL
     d                                2a   inz(x'0001')
      * Length of search argument
     d                                5u 0 inz(32)
     d                                5i 0 inz(0)
      * Occurrence count = 1
     d                                5i 0 inz(1)
      * Return count
     d   rtn_cnt                      5i 0
      * Returned index entry info
     d   ent_len                      5u 0
     d   ent_off                      5i 0
      * Operand 4 of FNDINXEN, search argument
     d fnd_arg         ds
     d   inx_fmt                      1a   inz('1')
     d   fnd_jobnam                  10a
     d   fnd_jobusr                  10a
     d   fnd_jobnum                   6a
     d                                5a   inz(x'0000000000')
      * WCBTE
     d wcbte           ds                  qualified
     d                                     based(wcbte@)
     d                               32a
     d   pcs@                          *

     d me              pi
     d   jobnam                      10a
     d   jobusr                      10a
     d   jobnum                       6a
     d   pcs@                          *

STMT  /free
75         pco@ = pcoptr2();
76         wcbt@ = setsppfp(syp_qwcbt00@);

           fnd_jobnam = jobnam;
           fnd_jobusr = jobusr;
           fnd_jobnum = jobnum;
81         fndinxen (rcv : job_inx@ : opt_lst : fnd_arg);

83         pcs@ = wcbte.pcs@;
           *inlr = *on;
      /end-free
