     /**
      * @file autbits01.rpgle
      */
     h dftactgrp(*no) bnddir('QC2LE')

     d qsycvta         pr                  extpgm('QSYCVTA')
     d   miaut                        2a
     d   spcval                      10a
     d   numval                      10u 0
     d   ec                           8a
     d cvthc           pr                  extproc('cvthc')
     d                                2a   options(*varsize)
     d                                1a   options(*varsize)
     d                               10u 0 value

     d miaut           s              2a
     d ARRELMT         c                   16
     d                 ds
     d spcvali                      256a   inz(
     d                                     '*OBJEXIST +
     d                                      *OBJMGT   +
     d                                      *OBJOPR   +
     d                                      *READ     +
     d                                      *ADD      +
     d                                      *DLT      +
     d                                      *UPD      +
     d                                      *EXCLUDE  +
     d                                      *AUTLMGT  +
     d                                      *EXECUTE  +
     d                                      *OBJALTER +
     d                                      *OBJREF   +
     d                                      *AUTL     +
     d                                      *USE      +
     d                                      *CHANGE   +
     d                                      *ALL      ')
     d spcval                        10a   dim(ARRELMT)
     d                                     overlay(spcvali)
     d msg             ds                  qualified
     d   spcval                      10a
     d                                1a
     d   miaut                        4a
     d num             s             10u 0 inz(1)
     d ec              s              8a   inz(*allx'00')
     d i               s              5u 0

      /free
           for i = 1 to ARRELMT;
               qsycvta(miaut : spcval(i) : num : ec);
               msg.spcval = spcval(i);
               cvthc(msg.miaut : miaut : 4);
               dsply msg '';
           endfor;

           *inlr = *on;
      /end-free
