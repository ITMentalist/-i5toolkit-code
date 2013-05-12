     /**
      * @file struag.rpgle
      *
      * Start a user activation group
      */

      /copy mih-ptr
      /copy mih-pgmexec

     /**
      * PEP Prototype of STRUAG
      */
     d main_proc       pr                  extpgm('STRUAG')
     d   agp_mark                    20u 0

      * Prototype of CL module STRUAG_DQ
     d chk_dtaq        pr                  extproc('STRUAG_DQ')
      * Prototype subprocedure rcd_agp
     d rcd_agp         pr
     d   agp_mark                    20u 0
     d   actmk_callx                 20u 0
      * Prototype of C library routine cvthc()
     d cvthc           pr                  extproc('cvthc')
     d                                1a   options(*varsize)
     d                                 *   value
     d                               10u 0 value

     d pgmnew          s               *
     d PGMNEW_NAME     c                   'PGMNEW'
     d CALLX_NAME      c                   'CALLX'
     d actdfn          ds                  likeds(actbpgm_dfn2_t)
     d actspec         ds                  likeds(actbpgm_pgm_spec2_t)
     d @actspec        s               *   inz(%addr(actspec))
     d hex_mark        s             16a

     d main_proc       pi
     d   agp_mark                    20u 0

      /free
           // [1] Start a new user ACTGRP
           // [1.1] Resolve system pointer to PGMNEW
           rslvsp_tmpl.obj_type = x'0201';
           rslvsp_tmpl.obj_name = PGMNEW_NAME;
           rslvsp2(pgmnew : rslvsp_tmpl);

           // [1.2] Start a new activation group by
           //       activating ACTGRP(*NEW) program PGMNEW
           actdfn = *allx'00';
           actbpgm2(actdfn : pgmnew);

           // [2] Activate *SRVPGM CALLX into the newly
           //     started user activation group
           actspec = *allx'00';
           // [2.1] Resolve system pointer to *SRVPGM CALLX
           rslvsp_tmpl.obj_type = x'0203';
           rslvsp_tmpl.obj_name = CALLX_NAME;
           rslvsp2(actspec.pgm : rslvsp_tmpl);

           // [2.2] Activate *SRVPGM CALLX in the USRAGP
           actspec.tgt_agp = actdfn.agp_mark;
           actdfn = *allx'00';
           actbpgm2(actdfn : @actspec);

           // [3] Record agp-mark, act-mark of callx
           chk_dtaq();
           rcd_agp( actdfn.agp_mark
                  : actdfn.act_mark );

           // [4] Set output agp-mark or report it to the user
           if %parms() > 0;
               agp_mark = actdfn.agp_mark;
           else;
               cvthc( hex_mark
                    : %addr(actdfn.agp_mark)
                    : 16 );
               dsply 'Activation group mark (hex)'
                     '' hex_mark;
           endif;

           *inlr = *on;
      /end-free

     /**
      * @func rcd_agp
      * Record the AGP mark and the activation mark of
      * *SRVPGM CALLX in *DTAQ QTEMP/USRAGP.
      */
     p rcd_agp         b
     d do_enq          pr                  extpgm('QSNDDTAQ')
     d   q_name                      10a
     d   q_lib                       10a
     d   msg_len                      5p 0
     d   msg                         20u 0
     d   key_len                      3p 0
     d   key                         20u 0

     d DTAQ_NAME       s             10a   inz('USRAGP')
     d DTAQ_LIB        s             10a   inz('QTEMP')
     d msg_len         s              5p 0 inz(8)
     d key_len         s              3p 0 inz(8)

     d rcd_agp         pi
     d   agp_mark                    20u 0
     d   actmk_callx                 20u 0
      /free
           // Enqueue a message to *DTAQ QTEMP/USRAGP
           //   Key=AGP mark
           //   Message=Activation mark of *SRVPGM CALLX
           do_enq( DTAQ_NAME
                 : DTAQ_LIB
                 : msg_len
                 : actmk_callx
                 : key_len
                 : agp_mark );
      /end-free
     p                 e
