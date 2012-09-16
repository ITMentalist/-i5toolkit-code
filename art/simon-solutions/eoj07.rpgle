      * @file eoj07.rpgle
     h dftactgrp(*no) bnddir('QC2LE') actgrp('EOJ07')
      * Prototype of system BIF _RSLVSP2
     d rslvsp2         pr                  extproc('_RSLVSP2')
     d   syp                           *   procptr
     d   opt                         34a   options(*varsize)
      * Prototype of atiexit()
     d atiexit         pr            10i 0 extproc('atiexit')
     d   exit_pgm                      *   value procptr
     d   exit_arg                     1a   options(*varsize)
      * Prototype of atexit()
     d atexit          pr            10i 0 extproc('atexit')
     d   exit_proc                     *   value procptr
      * Prototype of the Abnormal End (CEE4ABN) API
     d cee4abn         pr
     d   raise_TI                    10i 0
     d   cel_rc_mod                  10i 0
     d   user_rc                     10i 0
      * Prototype of the Register Activation Group Exit
      * Procedure (CEE4RAGE) API
     d cee4rage        pr
     d   exit_proc                     *   procptr
     d   fc                          12a

     d eoj08           s               *   procptr
     d rt              s             34a
     d arg             s             50a   inz('atiexit')
     d r               s             10i 0
     d a               s             10i 0 inz(0)
     d b               s             10i 0 inz(0)
     d c               s             10i 0 inz(0)

      * Prototype of the ACTGRP exit procedure register by atexit()
     d agp_exit        pr
      * Prototype of the ACTGRP exit program register by atiexit()
     d agp_exit2       pr
      *
      * Prototype of me -- EOJ07
      *
      * Set @var flag to A to end the current ACTGRP abnormally.
      *
     d i_main          pr                  extpgm('EOJ07')
     d   flag                         1a

     d   ag_mark                     10u 0
     d   reason                      10u 0
     d   result_code                 10u 0
     d   user_rc                     10u 0
     d exit_proc       s               *   procptr
     d fc              s             12a

     d i_main          pi
     d   flag                         1a

      /free
           // Resolve a SYSPTR to ACTGRP exit program EOJ08
           rt = *allx'00';
           %subst(rt:1:2) = x'0201';
           %subst(rt:3:30) = *blanks;
           %subst(rt:3:10) = 'EOJ08';
           rslvsp2(eoj08 : rt);

           // Register ACTGRP exit procedures/program
           r = atiexit(eoj08 : arg);
           r = atexit(%paddr(agp_exit));
           exit_proc = %paddr(agp_exit2);
           cee4rage(exit_proc : fc);

           if flag = 'a' or flag = 'A';
               // End the current ACTGRP abnormally
               cee4abn(a : b : c);
           endif;
           *inlr = *on;
      /end-free

     p agp_exit        b
     d agp_exit        pi
      /free
           dsply 'AGP-EXIT - atexit' 'QSYSOPR';
      /end-free
     p                 e

     p agp_exit2       b
     d agp_exit2       pi
     d   ag_mark                     10u 0
     d   reason                      10u 0
     d   result_code                 10u 0
     d   user_rc                     10u 0

      /free
           dsply 'AGP-EXIT - CEE4RAGE' 'QSYSOPR';
      /end-free
     p                 e
