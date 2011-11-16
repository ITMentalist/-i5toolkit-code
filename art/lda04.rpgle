     h dftactgrp(*no)

      /copy mih-prcthd
      /copy mih-ptr
     d @pco            s               *
     d pco             ds                  qualified
     d                                     based(@pco)
     d                                 *   dim(35)
     d   lda                           *
     d   ldaproc                       *   overlay(lda)
     d                                     procptr
     d ldaspcptr                       *
     d ldaspc          ds                  qualified
     d                                     based(ldaspcptr)
     d                                8a
     d   start                        5u 0
     d ldaaraptr       s               *
     d ldaara          ds                  qualified
     d                                     based(ldaaraptr)
     d   ldatype                      1a
     d   ldalen                       5u 0
     d   dta                       1024a
     d func            s               *   procptr
     d i               s             10i 0

     d addi            pr            10i 0 extproc(func)
     d   addent1                     10i 0 value
     d   addent2                     10i 0 value

      /free
           @pco = pcoptr2();
           ldaspcptr = setsppfp(pco.ldaproc);
           // check ldaspc.start
           ldaaraptr = ldaspcptr + ldaspc.start;

           // call procedure via the PROCPTR stored in the LDA
           cpybwp( %addr(func)
                 : %addr(ldaara.dta)
                 : 16 );
           i = addi(955 : 6);
           dsply 'i' '' i;

           *inlr = *on;
      /end-free
