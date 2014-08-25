     /**
      * @file xfronrt2.rpgle
      *
      * Test of XFRONR.
      * Transfer the ownership of obj@ to user@.
      * @param [in] User profile name
      * @param [in] Object name
      * @param [in] 2-byte MI object type/subtype code
      */

     h dftactgrp(*no)
      * Basic resolve option template of the RSLVSP instruction
     d rslv_opt        ds                  qualified
     d     obj_type                   2a
     d     obj_name                  30a
      * required authorization
     d     auth                       2a   inz(x'0000')
      * Prototype of SYSBIF _RSLVSP2
     d rslvsp2         pr                  extproc('_RSLVSP2')
     d   obj                           *
     d   opt                         34a
      * Prototype of XFRONR
     d xfronr          pr                  extpgm('XFRONR')
     d   user@                         *
     d   obj@                          *
      * Prototype of XFRONRT2
     d me              pr                  extpgm('XFRONRT2')
     d   user                        30a
     d   obj                         30a
     d   objtyp                       2a

     d user@           s               *
     d obj@            s               *
     d me              pi
     d   user                        30a
     d   obj                         30a
     d   objtyp                       2a

      /free
           rslv_opt.obj_type = x'0801';
           rslv_opt.obj_name = user;
           rslvsp2(user@ : rslv_opt);

           rslv_opt.obj_type = objtyp;
           rslv_opt.obj_name = obj;
           rslvsp2(obj@ : rslv_opt);

           xfronr(user@ : obj@);
           *inlr = *on;
      /end-free
