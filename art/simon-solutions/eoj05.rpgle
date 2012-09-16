      * @file eoj05.rpgle
      *
      * call eoj06
     h dftactgrp(*no) bnddir('QC2LE')

      /if defined(HAVE_I5TOOLKIT)
      /copy mih-undoc
      /else
      * Jump buffer structure
     d jmp_buf_t       ds                  qualified
     d     inv_ptr                     *
     d     lbl_ptr                     *
     d     num                       10i 0
      * @BIF __setjmp
     d setjmp          pr            10i 0 extproc('__setjmp')
     d     jmpbuf                          likeds(jmp_buf_t)
      /endif

     d pos             ds                  likeds(jmp_buf_t)

      * EOJ06
     d eoj06           pr                  extpgm('EOJ06')
     d   pos                               likeds(jmp_buf_t)

      /free
           // Save current stack environment
           if setjmp(pos) = -1;
               // SIGTERM is caught
               dsply 'Stack enviroment restored'
                     'QSYSOPR';
           else;
               // 
               eoj06(pos);
           endif;

           // Do end-of-job cleanup
           dsply 'Doing cleanup' 'QSYSOPR';
           *inlr = *on;
      /end-free
