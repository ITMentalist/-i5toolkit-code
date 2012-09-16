      * @file eoj04.rpgle
     h dftactgrp(*no) bnddir('QC2LE')

      * Prototype of sigemptyset() (Initialize and empty signal set)
     d sigemptyset     pr            10i 0 extproc('sigemptyset')
     d   set                          8a
      * Prototype of sigaddset() (Add signal to signal set)
     d sigaddset       pr            10i 0 extproc('sigaddset')
     d   set                          8a
     d   sig                         10i 0 value
      * Prototype of sigprocmask() (Examine and change blocked signals)
     d sigprocmask     pr            10i 0 extproc('sigprocmask')
     d   how                         10i 0 value
     d   new_set                      8a   const
     d   old_set                      8a   options(*omit)
      * Signal action structure
     d sigaction_t     ds                  qualified
     d   sa_handler                    *   procptr
     d   sa_mask                      8a
     d   sa_flags                    10i 0
     d   sa_sigaction                  *   procptr
      * Prototype of sigaction() (Examine and change signal action)
     d sigaction       pr            10i 0 extproc('sigaction')
     d   sig                         10i 0 value
     d   act                               likeds(sigaction_t)
     d                                     const
     d   oact                              likeds(sigaction_t)
     d                                     options(*omit)
     d SIGTERM         c                   6
     d SIG_BLOCK       c                   0
     d SIG_UNBLOCK     c                   1

      * Prototype of longjmp()
     d longjmp         pr                  extproc('longjmp')
     d   jmp_buf                           likeds(jmp_buf_t)
     d   val                         10i 0 value
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

     d act             ds                  likeds(sigaction_t)
     d r               s             10i 0 inz(0)
     d pos             ds                  likeds(jmp_buf_t)

      * Prototype of sleep() (Suspend processing for interval of time)
     d sleep           pr            10u 0 extproc('sleep')
     d   seconds                     10u 0 value
      * Prototype of signal-handler
     d oops            pr
     d   sig                         10i 0 value

      /free
           // Register signal-handler for SIGTERM
           act.sa_flags = 0;
           act.sa_handler = %paddr(oops);
           r = sigemptyset(act.sa_mask);
           r = sigaddset(act.sa_mask : SIGTERM);
           r = sigaction(SIGTERM : act : *omit);

           // Save current stack environment
           if setjmp(pos) = -1;
               // SIGTERM is caught
               dsply 'Stack enviroment restored' 'QSYSOPR';
           else;
               // Do my works, please don't disturb me!
               // Block SIGTERM
               sigprocmask( SIG_BLOCK
                          : act.sa_mask
                          : *OMIT);
               sleep(30);
               // Unblock SIGTERM
               sigprocmask( SIG_UNBLOCK
                          : act.sa_mask
                          : *OMIT);
           endif;

           // Do end-of-job cleanup
           dsply 'Doing cleanup' 'QSYSOPR';
           *inlr = *on;
      /end-free

      * Signal-handler
     p oops            b
     d oops            pi
     d   sig                         10i 0 value
      /free
           dsply 'Inside signal-handler' 'QSYSOPR';
           // Jump to the saved stack environment
           longjmp(pos : -1);
      /end-free
     p                 e
