     /**
      * @file autbits02.rpgle
      */
     h dftactgrp(*no)

      /copy mih-ptr

     d qsycvta         pr                  extpgm('QSYCVTA')
     d   miaut                        2a
     d   spcval                      10a
     d   numval                      10u 0
     d   ec                           8a

     d spcx            s               *
     d aut_change      s             10a   inz('*CHANGE')
     d num             s             10u 0 inz(1)
     d ec              s              8a   inz(*allx'00')

      /free
           rslvsp_tmpl.obj_type = x'1934';
           rslvsp_tmpl.obj_name = 'SPCX';
           qsycvta( rslvsp_tmpl.auth
                  : aut_change
                  : num
                  : ec ); // Convert *CHANGE to MI auth-value
           rslvsp2( spcx : rslvsp_tmpl );
             // Check SYSPTR spcx

           *inlr = *on;
      /end-free
