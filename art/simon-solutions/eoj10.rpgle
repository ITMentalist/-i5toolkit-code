     h dftactgrp(*no) bnddir('QC2LE')
      * Prototype of CEERTX
     d ceertx          pr                  extproc('CEERTX')
     d   @exit_proc                    *   procptr
     d   @exit_arg                     *   options(*omit)
     d   fc                          12a   options(*omit)
      * Prototype of CEEUTX
     d ceeutx          pr                  extproc('CEEUTX')
     d   @exit_proc                    *   procptr
     d   fc                          12a   options(*omit)
      * Prototype of libc routine sleep()
     d sleep           pr            10i 0 extproc('sleep')
     d                               10u 0 value
      * Invocation exit procedure
     d inv_exit        pr
     d   @arg                          *

     d @exit_proc      s               *   procptr
     d                                     inz(%paddr(inv_exit))
     d @arg            s               *   inz(%addr(hello))
     d hello           s             20a   inz('Hello from INV-EXIT')

      /free
           ceertx(@exit_proc : @arg : *omit);
           sleep(600);
           *inlr = *on;
      /end-free

     p inv_exit        b
     d eoj12           pr                  extpgm('EOJ12')
     d inv_exit        pi
     d   @arg                          *
     d arg             s             20a   based(@arg)
      /free
           eoj12();
           dsply 'Exit Arg' '' arg;
      /end-free
     p                 e
