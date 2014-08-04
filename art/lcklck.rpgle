     /**
      * @file lcklck.rpgle
      *
      * Lock/Unlock an MI object idendified by a system pointer.
      * @param [in] SYSPTR to the MI object
      * @param [in] Requested lock state
      * @param [in] Flag. 'U' = Unlock, anything else = Lock
      */

     h dftactgrp(*no) actgrp('LCKLCK')

     d lock_request    ds                  qualified
     d     num_requests...
     d                               10i 0 inz(1)
     d     offset_lock_state...
     d                                5i 0 inz(32)
     d     time_out                  20u 0
     d     lock_opt                   2a   inz(x'4200')
     d     obj@                        *
     d     lock_state                 1a
     d                               15a
      * Lock request option related constants
     d LOCK_REQUEST_TYPE_IMMED...
     d                 c                   x'0000'
     d LOCK_REQUEST_TYPE_SYNC...
     d                 c                   x'4000'
     d LOCK_REQUEST_TYPE_ASYNC...
     d                 c                   x'8000'
     d LOCK_WAIT_4EVER...
     d                 c                   x'0200'
     d LOCK_SCOPED_TO_OBJ...
     d                 c                   x'0000'
     d LOCK_SCOPED_TO_THREAD...
     d                 c                   x'0080'
     d LOCK_SCOPE_OBJ_MI_PROCESS...
     d                 c                   x'0000'
     d LOCK_SCOPE_OBJ_TCS...
     d                 c                   x'0040'
      * The Lock Object (LOCK) MI instruction
     d lockobj         pr                  extproc('_LOCK')
     d     lock_request...
     d                                     likeds(lock_request)
      * The Unlock Object (UNLOCK) MI instruction
     d unlockobj       pr                  extproc('_UNLOCK')
     d     unlock_request...
     d                                     likeds(lock_request)
      * Prototype of the LCKLCK program
     d i_main          pr                  extpgm('LCKLCK')
     d     object                      *
     d     lock_state                 1a
     d     flag                       1a

     d i_main          pi
     d     object@                     *
     d     lock_state                 1a
     d     flag                       1a

      /free
           lock_request.lock_opt = %bitor(
             LOCK_REQUEST_TYPE_SYNC
             : LOCK_WAIT_4EVER
             : LOCK_SCOPED_TO_OBJ
             : LOCK_SCOPE_OBJ_MI_PROCESS );
           lock_request.obj@ = object@;
           lock_request.lock_state = lock_state;
           if flag = 'U';
               unlockobj(lock_request);
           else;
               lockobj(lock_request);
           endif;

           *inlr = *on;
      /end-free
