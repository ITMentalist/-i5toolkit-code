
      /if defined(*crtbndrpg)
     h  dftactgrp(*no)
      /endif
     h bnddir('QC2LE')

      /copy mih52
     d mutex_t         ds                  qualified
     d     ctrl_area                 16a
     d     name                      16a

     d crtmtx_option_t...
     d                 ds                  qualified
     d                                1a
     d     name_opt                   1a
     d     keep_valid_opt...
     d                                1a
     d     recursive_opt...
     d                                1a
     d                               28a

     /**
      * CRTMTX (create pointer-based mutex)
      *
      * @return 0 if the mutex is created; otherwise an error number.
      */
     d desmtx          pr            10i 0 extproc('_DESMTX')
     d     mtx_addr                    *   value
     d     des_opt                     *   value

     /**
      * DESMTX (destroy pointer-based mutex)
      *
      * @return 0 if the mutex is created; otherwise an error number.
      */
     d crtmtx          pr            10i 0 extproc('_CRTMTX')
     d     mtx_addr                    *   value
     d     crt_opt                     *   value

     d cvthc           pr                  extproc('cvthc')
     d     receiver                    *   value
     d     source                      *   value
     d     length                    10i 0 value

     d mtx             ds                  likeds(mutex_t)
     d crtopt          ds                  likeds(crtmtx_option_t)
     d desopt          s             10i 0 inz(0)
     d buf             s             32a
     d rtn             s             10i 0

      /free
           mtx.name = 'Hello mutex';
           propb (%addr(crtopt) : x'00' : %size(crtopt));
           crtopt.name_opt       = x'01';
           crtopt.keep_valid_opt = x'00';
           crtopt.recursive_opt  = x'01';
           rtn = crtmtx(%addr(mtx) : %addr(crtopt));

           if rtn <> 0;
               dsply '_CRTMTX failed' '' rtn;
           else;
               dsply 'mutex created' '' rtn;
           endif;

           // destroy mutext
           desopt = 0;
           rtn = desmtx(%addr(mtx) : %addr(desopt));

           *inlr = *on;
      /end-free
