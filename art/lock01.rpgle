     /**
      * @file lock01.rpgle
      *
      * 
      */
     h dftactgrp(*no)
      /copy mih-lock
      /copy mih-ptr
     d main            pr                  extpgm('LOCK01')
     d   request_type                 1a

     d lock_request    ds                  qualified
     d   base                              likeds(lock_request_tmpl_t)
     d   obj                           *
     d   lock_state                   1a

     d main            pi
     d   request_type                 1a

      /free
           lock_request.base = *allx'00';
           lock_request.base.num_requests = 1;
           lock_request.base.offset_lock_state = 32;
           lock_request.base.lock_opt = x'4200'; // Synchronous request
                                                 // and wait indefinitely.
           // Lock myself
           rslvsp_tmpl.obj_type = x'0201';
           rslvsp_tmpl.obj_name = 'LOCK01';
           rslvsp2(lock_request.obj : rslvsp_tmpl);
           lock_request.lock_state = x'09';      // LENR lock
           if request_type = 'I';
               lock_request.base.lock_opt = x'0200'; // Immediate request
           elseif request_type = 'A';
               lock_request.base.lock_opt = x'8200'; // Asynchronous request
           endif;

           lockobj(lock_request);  // Lock myself with specified lock request type
           *inlr = *on;
      /end-free
