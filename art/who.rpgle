     /**
      * @file who.rpgle
      *
      * Test of who_am_i().
      *
      * Output of WHO:
      * @code
      * DSPLY  Program:         LSBIN/WHO 
      * DSPLY  Module:          QTEMP/WHO 
      * DSPLY  Procedure:       WHO       
      * DSPLY  Statement ID:            81
      * @endcode
      */
     h dftactgrp(*no)

     /**
      * DS used by who_am_i() to represent program info.
      */
     d pgm_info_t      ds                  qualified
     d     ctx                       30a
     d     name                      30a

     /**
      * DS used by who_am_i() to represent module info.
      */
     d module_info_t   ds                  qualified
     d     name                      30a
     d     qualifier                 30a

     /**
      * DS used to represent variable length procedure name.
      */
     d proc_name_t     ds                  qualified
     d                                     based(dummy_ptr)
     d     len                        5u 0
     d     name                   32767a

     /**
      * DS used to represent statement ID list.
      */
     d stmt_list_t     ds                  qualified
     d                                     based(dummy_ptr)
     d     num                        5u 0
     d     stmt                      10i 0 dim(1024)

     /**
      * Who am I?
      *
      * @param [out] pgm_info, returned program info.
      * @param [out] mod_info, returned module info.
      * @param [out] proc_name, returned procedure name.
      * @param [out] stmst, returned statement ID list.
      * @param [in]  inv_offset, offset of target invocation.
      *              -1 if no passed, which means who_am_i()'s caller.
      *
      * @return 1-byte invocation type.
      *         hex 00 = Non-bound program
      *         hex 01 = Bound program
      *         hex 02 = Bound service program
      *         hex 04 = Java program
      *         hex FF = invalid input parameters
      */
     d who_am_i        pr             1a
     d     pgm_info                        likeds(pgm_info_t)
     d     mod_info                        likeds(module_info_t)
     d     proc_name                       likeds(proc_name_t)
     d     stmts                           likeds(stmt_list_t)
     d     inv_offset                10i 0 value options(*nopass)

     d pgm_info        ds                  likeds(pgm_info_t)
     d mod_info        ds                  likeds(module_info_t)
     d proc_name       ds                  likeds(proc_name_t)
     d                                     based(proc_name_ptr)
     d proc_name_ptr   s               *
     d stmts           ds                  likeds(stmt_list_t)
     d                                     based(stmts_ptr)
     d stmts_ptr       s               *
     d pgm_type        s              1a
     d msg             s             30a

      /free

           proc_name_ptr = %alloc(2 + 128);
           proc_name.len = 128;

           stmts_ptr = %alloc(2 + 4 * 4); // for up to 4 statement ids
           stmts.num = 4;

           pgm_type = who_am_i( pgm_info
                              : mod_info
                              : proc_name
                              : stmts );

           // check returned information
           // program info
           msg = %trim(%subst(pgm_info.ctx : 1 : 10)) + '/'
                 + %subst(pgm_info.name : 1 : 10);
           dsply 'Program:     ' '' msg;

           if pgm_type > x'00';
               // module info
               msg = %trim(%subst(mod_info.qualifier : 1 : 10)) + '/'
                     + %subst(mod_info.name : 1 : 10);
               dsply 'Module:      ' '' msg;

               // procedure name
               msg = %subst(proc_name.name : 1 : proc_name.len);
               dsply 'Procedure:   ' '' msg;

               // first statement ID in stmt id list
               dsply 'Statement ID:' '' stmts.stmt(1);
           endif;

           *inlr = *on;
      /end-free

     /* implementation of who_am_i */
     p who_am_i        b

      /copy mih52

     d who_am_i        pi             1a
     d     pgm_info                        likeds(pgm_info_t)
     d     mod_info                        likeds(module_info_t)
     d     proc_name                       likeds(proc_name_t)
     d     stmts                           likeds(stmt_list_t)
     d     inv_offset                10i 0 value options(*nopass)

     d inv_id          ds                  likeds(invocation_id_t)
     d susptr          ds                  likeds(matinvat_ptr_t)
     d sel             ds                  likeds(matinvat_selection_t)
     d ptrd            ds                  likeds(matptrif_susptr_tmpl_t)
     d mask            s              4a

      /free
           // initialize invocation id
           inv_id = *allx'00';
           if %parms() > 4;
               if inv_offset > 0;
                   return x'FF';
               endif;
               inv_id.src_inv_offset = inv_offset;
           else;
               inv_id.src_inv_offset = -1;  // caller's invocation
           endif;

           // materialize suspend pointer of target invocation
           sel = *allx'00';
           sel.num_attr   = 1;
           sel.attr_id    = 24;  // suspend pointer
           sel.rcv_length = 16;
           matinvat2( %addr(susptr)
                    : inv_id
                    : %addr(sel) );

           // materialize suspend ptr
           ptrd = *allx'00';
           ptrd.bytes_in = %size(ptrd);
           ptrd.proc_name_length_in = proc_name.len;
           ptrd.proc_name_ptr = %addr(proc_name.name);
           ptrd.stmt_ids_in = stmts.num;
           ptrd.stmt_ids_ptr = %addr(stmts.stmt);
           mask = x'5B280000';  // 01011011,00101000,00000000,00000000
             // bit 1 = 1, materialize program type
             // bit 3 = 1, materialize program context
             // bit 4 = 1, materialize program name
             // bit 6 = 1, materialize module name
             // bit 7 = 1, materialize module qualifier
             // bit 10 = 1, materialize procedure name
             // bit 12 = 1, materialize statement id list
           matptrif( ptrd : susptr.ptr : mask );

           // set output parameters
           pgm_info.ctx       = ptrd.pgm_ctx;
           pgm_info.name      = ptrd.pgm_name;
           mod_info.name      = ptrd.mod_name;
           mod_info.qualifier = ptrd.mod_qual;
           proc_name.len      = ptrd.proc_name_length_out;
           stmts.num          = ptrd.stmt_ids_out;

           // return materialized program type
           return ptrd.pgm_type;
      /end-free
     p who_am_i        e
