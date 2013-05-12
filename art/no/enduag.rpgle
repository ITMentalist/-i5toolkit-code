     /**
      * @file enduag.rpgle
      *
      * End a user activation group
      */

      /copy mih-ptr
      /copy mih-pgmexec

     /**
      * Prototype of ENDUAG
      */
     d main_proc       pr                  extpgm('ENDUAG')
     d   agp_mark                    20u 0

     d main_proc       pi
     d   agp_mark                    20u 0

     d get_callx_mark  pr            20u 0
     d   agp_mark                    20u 0 value
     d   remove                        n   value
     d resolve_callxx  pr              *   procptr
     d   act_mark                    20u 0 value

     d callx_mark      s             20u 0
     d argc            s             10u 0 inz(0)
     d argv            s               *   dim(1)
     d callxx          s               *   procptr
     d callee          s               *
     d EOAG_PGM        c                   'EOAG'
     d callxx_proc     pr                  extproc(callxx)
     d     pgm_ptr                     *
     d     argv                        *   dim(1) options(*varsize)
     d     argc                      10u 0 value

      /free
           // [1] Dequeue act-mark of *srvpgm CALLX by agp-mark
           callx_mark = get_callx_mark(agp_mark : *off);
           if callx_mark = 0;  // Failed to find target UAG
               // Error handling
               *inlr = *on;
               return;
           endif;

           // [2] Resolve PROCPTR to proceture callxx
           callxx = resolve_callxx(callx_mark);
           if callxx = *NULL;
               // Error handling
               *inlr = *on;
               return;
           endif;

           // [3] Resolve a SYP to the EOAG program
           rslvsp_tmpl.obj_type = x'0201';
           rslvsp_tmpl.obj_name = EOAG_PGM;
           rslvsp2(callee : rslvsp_tmpl);

           // [4] Call EOAG via CALLXX
           callxx_proc( callee : argv : argc );

           // [5] Remove UAG entry from *DTAQ USRAGP
           get_callx_mark(agp_mark : *on);

           *inlr = *on;
      /end-free

     /**
      * Return the activation mark of *SRVPGM CALLX in
      * the target activation group.
      * @remark 0 is returned is target group is NOT found.
      */
     p get_callx_mark  b
     d do_deq          pr                  extpgm('QRCVDTAQ')
     d   q_name                      10a
     d   q_lib                       10a
     d   msg_len                      5p 0
     d   msg                         20u 0
     d   timeout                      5p 0
     d   key_order                    2a
     d   key_len                      3p 0
     d   key                         20u 0
     d   sender_len                   3p 0
     d   sender_info                  1a
     d   rmv_flag                    10a
     d   rcv_len                      5p 0
     d   deq_ec                       8a

     d DTAQ_NAME       s             10a   inz('USRAGP')
     d DTAQ_LIB        s             10a   inz('QTEMP')
     d msg_len         s              5p 0 inz(8)
     d key_len         s              3p 0 inz(8)
      * Do NOT wait!
     d timeout         s              5p 0 inz(0)
     d key_order       s              2a   inz('EQ')
     d sender_len      s              3p 0 inz(0)
     d sender_info     s              1a
      * Do NOT remove queue message
     d rmv_flag        s             10a   inz('*NO')
     d rcv_len         s              5p 0 inz(8)
     d deq_ec          s              8a   inz(x'0000000800000000')

     d act_mark        s             20u 0

     d get_callx_mark  pi            20u 0
     d   agp_mark                    20u 0 value
     d   remove                        n   value

      /free
           if remove; // Remove queue message?
               rmv_flag = '*YES';
           endif;

           do_deq( DTAQ_NAME
                 : DTAQ_LIB
                 : msg_len
                 : act_mark
                 : timeout
                 : key_order
                 : key_len
                 : agp_mark
                 : sender_len
                 : sender_info
                 : rmv_flag
                 : rcv_len
                 : deq_ec );
           if msg_len = 0;  // No such UAG!
               act_mark = 0;
           endif;

           return act_mark;
      /end-free
     p                 e

     /**
      * Resolve a procedure pointer to callxx() which
      * is exported by *SRVPGM CALLX.
      */
     p resolve_callxx  b
     d QleGetExpLong   pr                  extproc('QleGetExpLong')
     d   act_mark                    20u 0
     d   exp_id                      10i 0
     d   exp_name_len                10i 0
     d   exp_name                     1a   options(*varsize)
      * Pointer addressing the returned export
     d   exp_ptr                       *   procptr
      * Export type. 0=Not found, 1=procedure, 2=data
     d   exp_type                    10i 0
     d   ec                           8a

     d exp_id          s             10i 0 inz(1)
     d exp_name_len    s             10i 0 inz(0)
     d exp_name        s              1a
     d exp_ptr         s               *   procptr
     d exp_type        s             10i 0 inz(0)
     d ec              s              8a   inz(x'0000000800000000')

     d resolve_callxx  pi              *   procptr
     d   act_mark                    20u 0 value

      /free
           QleGetExpLong( act_mark
                        : exp_id
                        : exp_name_len
                        : exp_name
                        : exp_ptr
                        : exp_type
                        : ec );
           if exp_type = 0;
               return *null;
           endif;

           return exp_ptr;
      /end-free
     p                 e
