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
     d funcptr         s               *   procptr
     d i               s             10i 0

     d func            pr            10i 0 extproc(funcptr)
     d   parm1                       10i 0 value
     d   parm2                       10i 0 value

      /free
           // Locate the LDA pointer in the PCO
           @pco = pcoptr2();
           // Address the associated space of the LDA
           ldaspcptr = setsppfp(pco.ldaproc);
           // Offset to the actual data area portion
           ldaaraptr = ldaspcptr + ldaspc.start;

           // Load PROCPTR funcptr from the LDA
           cpybwp( %addr(funcptr)
                 : %addr(ldaara.dta)
                 : 16 );
           // Call target procedure via PROCPTR funcptr
           i = func(955 : 6);
           dsply 'i' '' i;

           *inlr = *on;
      /end-free
