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

     d addi            pr            10i 0
     d   addent1                     10i 0 value
     d   addent2                     10i 0 value

      /free
           @pco = pcoptr2();
           ldaspcptr = setsppfp(pco.ldaproc);
           // check ldaspc.start
           ldaaraptr = ldaspcptr + ldaspc.start;

           // store procedure pointer in the LDA
           func = %paddr(addi);
           cpybwp( %addr(ldaara.dta)
                 : %addr(func)
                 : 16 );

           *inlr = *on;
      /end-free

     p addi            b
     d addi            pi            10i 0
     d   addent1                     10i 0 value
     d   addent2                     10i 0 value
      /free
           return (addent1 + addent2);
      /end-free
     p                 e
