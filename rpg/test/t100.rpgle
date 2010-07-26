     /**
      * @file t100.rpgle
      *
      *  - Resolve system pointer to *USRSPC *LIBL/SPR37.
      *  - Load PCS ptr stored by program SPR37 (see spr37.emi).
      *  - Transfer object locks to MI process identified by PCS ptr.
      *
      */

     h dftactgrp(*no)

      /copy mih52
     d spr37_t         ds                  qualified
     d                                     based(spp)
     d      pcs                        *
     d spp             s               *
      * system pointer to *USRSPC *LIBL/SPR37.
     d                 ds
     d spr37                           *
     d funny_ptr                       *   procptr
     d                                     overlay(spr37:1)
     d lock_req        ds                  likeds(lock_request_tmpl_t)
     d lock_req_ptr    s               *
     d TMPL_LEN        c                   128
     d pos             s               *
     d to_lock         s               *   based(pos)
     d lock_state      s              1a   based(pos)

     d

      /free
           rslvsp_tmpl.obj_type = x'1934';
           rslvsp_tmpl.obj_name = 'SPR37';
           rslvsp2(spr37 : rslvsp_tmpl);
           spp = setsppfp(funny_ptr);
             // check pcs

           // lock *USRQ THD0
           lock_req_ptr = %alloc(TMPL_LEN);
           propb(lock_req_ptr : x'00' : TMPL_LEN);
           lock_req.num_requests = 1;
           lock_req.offset_lock_state = min_lock_request_tmpl_length
                                        + 16;
           lock_req.time_out = 10 * sysclock_one_second;
           lock_req.lock_opt = x'4000';
           pos = lock_req_ptr + min_lock_request_tmpl_length;
           rslvsp_tmpl.obj_type = x'0A02';
           rslvsp_tmpl.obj_name = 'THD0';
           rslvsp2(to_lock : rslvsp_tmpl);

           pos += 16;



           // transfer locks to MI process identified by pcs


           *inlr = *on;
      /end-free
