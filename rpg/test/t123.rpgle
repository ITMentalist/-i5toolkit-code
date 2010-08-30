     /**
      * @file t123.rpgle
      *
      * Test of _MATINVAT2.
      */
     h dftactgrp(*no)

     d who_am_i        pr
      /free
           who_am_i();
           *inlr = *on;
      /end-free

     p who_am_i        b
      /copy mih52
     d inv_id          ds                  likeds(invocation_id_t)
     d susptr_info     ds                  likeds(matinvat_ptr_t)
     d sel             ds                  likeds(matinvat_selection_t)

     d ptrd            ds                  likeds(matptrif_susptr_tmpl_t)
     d mask            s              4a
     d proc_name       s             30a

      /free
           inv_id = *allx'00';
           inv_id.src_inv_offset = -1;  // caller

           sel = *allx'00';
           sel.num_attr   = 1;
           sel.attr_id    = 24;  // suspend pointer
           sel.rcv_length = 16;
           matinvat2( susptr_info
                    : inv_id
                    : sel );

           // materialize suspend ptr
           ptrd = *allx'00';
           ptrd.bytes_in = %size(ptrd);
           ptrd.proc_name_length_in = 30;
           ptrd.proc_name_ptr = %addr(proc_name);

           // materialize pointer desc
           mask = x'12200000';
             // bit 3 = 1; program name
             // bit 6 = 1; module name
             // bit 10 = 1; procedure name
           matptrif( ptrd : susptr_info.ptr : mask );

           // output pgm name, module name, and procedure name
           dsply '    Program name' '' ptrd.pgm_name;
           dsply '    Module name' '' ptrd.mod_name;

           if ptrd.proc_name_length_out > ptrd.proc_name_length_in;
               %subst(proc_name : 29 : 2) = ' <';
           endif;
           dsply '    Prodecure name' '' proc_name;

      /end-free
     p who_am_i        e
