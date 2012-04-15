     /**
      * @file lock02.rpgle
      */
     h dftactgrp(*no)
      /copy mih-lock
      /copy mih-ptr
     d main            pr                  extpgm('LOCK02')
     d   obj_name                    30a
     d   obj_type                     2a

      * System pointer to *USRSPC PCSPTR
     d                 ds
     d spcobj@                         *   procptr
     d spcobj                          *   overlay(spcobj@)
      * Space pointer addresses the associated space of *USRSPC PCSPTR
     d spp             s               *
     d                 ds                  based(spp)
     d   pcs                           *

     d lock_request    ds                  qualified
     d   base                              likeds(lock_request_tmpl_t)
     d   obj                           *
     d   lock_state                   1a

     d main            pi
     d   obj_name                    30a
     d   obj_type                     2a

      /free
           // Lock transfer request template
           lock_request.base = *allx'00';
           lock_request.base.num_requests = 1;
           lock_request.base.offset_lock_state = 32;
           lock_request.base.lock_opt = x'0000';
           rslvsp_tmpl.obj_type = obj_type;
           rslvsp_tmpl.obj_name = obj_name;
           rslvsp2(lock_request.obj : rslvsp_tmpl);
           lock_request.lock_state = x'09';      // LENR lock

           // Retrieve the PCS pointer of the receiving process
           rslvsp_tmpl.obj_type = x'1934';
           rslvsp_tmpl.obj_name = 'PCSPTR';
           rslvsp2(spcobj : rslvsp_tmpl);
           spp = setsppfp(spcobj@);

           // Transfer the lock to the receiving process
           xfrlock(pcs : lock_request);
           *inlr = *on;
      /end-free
