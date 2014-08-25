     /**
      * @file lckt1.rpgle
      *
      * Test of the LCKLCK program
      * @param [in] Char(30) object name
      * @param [in] Char(2) MI type/subtype code
      * @param [in] Char(1) Requested lock state
      * @param [in] Flag. 'U' = Unlock, anything else = Lock
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
      * Prototype of the LCKLCK program
     d lcklck          pr                  extpgm('LCKLCK')
     d     obj@                        *
     d     lcksts                     1a
     d     flag                       1a
      * Me
     d me              pr                  extpgm('LCKT1')
     d   obj                         30a
     d   objtyp                       2a
     d   lcksts                       1a
     d   flag                         1a

     d obj@            s               *
     d me              pi
     d   obj                         30a
     d   objtyp                       2a
     d   lcksts                       1a
     d   flag                         1a

      /free
           rslv_opt.obj_type = objtyp;
           rslv_opt.obj_name = obj;
           rslvsp2(obj@ : rslv_opt);

           lcklck(obj@ : lcksts : flag);
           *inlr = *on;
      /end-free
