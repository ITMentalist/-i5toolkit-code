     h dftactgrp(*no)

      /copy mih-prcthd
      /copy mih-ptr
     d i_main          pr                  extpgm('LDA03')
     d   flag                         1a

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

     d addi            pr            10i 0
     d   addent1                     10i 0 value
     d   addent2                     10i 0 value
      * round the sum to ten
     d addih           pr            10i 0
     d   addent1                     10i 0 value
     d   addent2                     10i 0 value

     d i_main          pi
     d   flag                         1a

      /free
           // Locate the LDA pointer in the PCO
           @pco = pcoptr2();
           // Address the associated space of the LDA
           ldaspcptr = setsppfp(pco.ldaproc);
           // Offset to the actual data area portion
           ldaaraptr = ldaspcptr + ldaspc.start;

           // Store selected procedure pointer in the LDA
           if %parms() > 0 and flag = 'H';
               funcptr = %paddr(addih);
           else;
               funcptr = %paddr(addi);
           endif;
           cpybwp( %addr(ldaara.dta)
                 : %addr(funcptr)
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

     p addih           b
     d addih           pi            10i 0
     d   addent1                     10i 0 value
     d   addent2                     10i 0 value
     d r               s             10i 0
     d addih           pr            10i 0
      /free
           r = (addent1 + addent2) / 10;
           return (r * 10);
      /end-free
     p                 e
