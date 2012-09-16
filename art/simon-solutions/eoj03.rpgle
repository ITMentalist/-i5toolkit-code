      * @file eoj03.rpgle
     h dftactgrp(*no)

      * Prototype of sigemptyset() (Initialize and empty signal set)
     d sigemptyset     pr            10i 0 extproc('sigemptyset')
     d   set                          8a
      * Prototype of sigaddset() (Add signal to signal set)
     d sigaddset       pr            10i 0 extproc('sigaddset')
     d   set                          8a
     d   sig                         10i 0 value
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

     d act             ds                  likeds(sigaction_t)
     d r               s             10i 0 inz(0)
     d bye             s               n   inz(*off)
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

           // Check @var bye periodically
           dow not bye;
               // Do my works
               sleep(5);
               dsply 'Sleepy ... zzz' 'QSYSOPR';
           enddo;

           // Do necessary cleanup works
           dsply 'Doing cleanup' 'QSYSOPR';

           dsply 'See you :p' 'QSYSOPR';
           *inlr = *on;
      /end-free

      * Signal-handler
     p oops            b
     d oops            pi
     d   sig                         10i 0 value
      /free
           dsply 'Inside signal-handler' 'QSYSOPR';
           // Set on @var bye
           bye = *on;
      /end-free
     p                 e
