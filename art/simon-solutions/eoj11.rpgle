     h dftactgrp(*no) bnddir('QC2LE')
      * API error code structure
     d qusec_t         ds                  qualified
     d                                     based(@dummy)
     d   bytes_in                    10i 0
     d   bytes_out                   10i 0
     d   msgid                        7a
     d                                1a
      * Message-specific message data

      * Prototype of the Send Scope Message (QMHSNDSM) API
     d QMHSNDSM        pr                  extpgm('QMHSNDSM')
     d   type                        10a
     d   scope_pgm                   20a
     d   arg                          1a   options(*varsize)
     d   arg_len                     10i 0
     d   msg_key                      4a
     d   ec                                likeds(qusec_t)
      * Prototype of libc routine sleep()
     d sleep           pr            10i 0 extproc('sleep')
     d                               10u 0 value

     d scope_type      s             10a   inz('*EXT')
     d scope_pgm       s             20a   inz('EOJ11     *LIBL')
     d arg             s             20a   inz('Hi, scope program!')
     d arg_len         s             10i 0 inz(32)
     d msg_key         s              4a
     d ec              ds                  likeds(qusec_t)
     d text            s             30a
     d eoj12           pr                  extpgm('EOJ12')

     d i_main          pr                  extpgm('EOJ11')
     d   greeting                    20a

     d i_main          pi
     d   greeting                    20a

      /free
           if %parms() > 0; // Now, EOJ11 works as a scope program.
               // Do cleanup works
               dsply 'Scope-handling program invoked' '';
               text = 'ARG: ' + greeting;
               dsply text '';
               dsply 'Cleanup, cleanup, cleanup ...' '';
               eoj12();
               *inlr = *on;
               return;
           endif;

           // Register myself as a *EXT scope-handling program
           ec.bytes_in = %len(ec);
           QMHSNDSM( scope_type
                   : scope_pgm
                   : arg
                   : arg_len
                   : msg_key
                   : ec);

           // Do my works
           dsply 'Doing my works ...' '';
           sleep(600);

           *inlr = *on;
      /end-free
