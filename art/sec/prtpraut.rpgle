     /**
      * @file prtpraut.rpgle
      *
      * Print privated authorities in an object.
      */

     h dftactgrp(*no)
     fQSYSPRT   o    f  132        disk
      /copy mih-ptr
      /copy mih-prcthd
      /copy mih-auth
      /copy mih-pgmexec
      * Authority value list DS
     d auth_val_lst_t  ds                  qualified
     d   num_auth                     5u 0
     d   auth_val                    10a   dim(11)
      * My prototype
     d i_main          pr                  extpgm('PRTPRAUT')
     d   obj_name                    10a
     d   obj_type                    10a
      * Convert MI authority bits to authority special values
     d cvt_auth_val    pr                  extproc('cvt_auth_val')
     d   mi_aut_val                   2a
     d   auth_val_lst                      likeds(auth_val_lst_t)
      * A speical prototype for system built-in _CALLPGMV
     d x               pr                  extproc('_CALLPGMV')
     d   callee                        *
     d   argv                         1a   options(*varsize)
     d   argc                        10u 0 value
      * Parameter list of QLICNV
      * 7a ex-type, 2a mi-type, 10a arrow
     d qlicnv_argv     ds
     d   ex_type                      7a
     d                                9a
     d   mi_type                      2a
     d                               14a
     d   arrow                       10a   inz('*SYMTOHEX')
     d                                 *
      * QLICNV's entry number in SEPT
     d QLICNV_ENTRY    c                   x'4A'

     d @pco            s               *
     d @sept           s               *   based(@pco)
     d sept            s               *   based(@sept)
     d                                     dim(7000)

     d obj             s               *
      * MATAUU option
     d mat_opt         s              1a   inz(x'32')
      * MATAUU materialization template
     d tmpl            ds                  likeds(matauu_tmpl_t)
     d                                     based(@tmpl)
     d authd           ds                  likeds(auth_desc_long_t)
     d                                     based(@authd)
     d len             s             10u 0
     d inx             s             10u 0
     d ws              s              1a
     d user            s             10a
     d prau            s            110a   based(@prau)
     d autlst          ds                  likeds(auth_val_lst_t)

     d i_main          pi
     d   obj_name                    10a
     d   obj_type                    10a

      /free
           // [1]
           // Call QLICNV to convert external object type to MI object type
           ex_type = %subst(obj_type : 2 : 7);
           @pco = pcoptr2();   // [1.1] Locate SEPT
           x ( sept(QLICNV_ENTRY)
             : qlicnv_argv
             : 3 );  // [1.2] Call QLICNV via SEPT

           // [2] Resolve target object
           rslvsp_tmpl.obj_name = obj_name;
           rslvsp_tmpl.obj_type = mi_type;
           rslvsp2 (obj : rslvsp_tmpl);

           // [3] Materialize private authorities in @var obj
           // [3.1] Allocate storage for the materialization tmplate
           mat_opt = x'32';
           @tmpl = modasa(8);
           tmpl.bytes_in = 8;
           matauu(@tmpl : obj : mat_opt);
           len = tmpl.bytes_out;
           @tmpl = modasa(len);

           // [3.2]
           // Materialize private authorized USRPRFs and
           // corresponding private authority states
           tmpl.bytes_in = len;
           matauu(@tmpl : obj : mat_opt);

           except OBJREC;
           // [3.3] Check each entry returned by MATAUU
           @authd = @tmpl + %size(matauu_tmpl_t); // size=16
           for inx = 1 to tmpl.num_private_users;
               // Set USER field in PRAUREC
               user = authd.usrprf_name;
 
               // [3.4] Convert MI auth-bits to special values
               autlst.num_auth = 0;
               cvt_auth_val( authd.private_auth : autlst);

               @prau = %addr(autlst) + 2; // PRAU field in PRAUREC
               except PRAUREC;

               // Next entry
               @authd += %size(auth_desc_long_t);
           endfor;

           *inlr = *on;
      /end-free

      * Output record formats
     oQSYSPRT   e            OBJREC
     o                       obj_name
     o                       ws
     o                       obj_type
      * Private authority for a USRPRF
     oQSYSPRT   e            PRAUREC
     o                       user
     o                       ws
     o                       prau

     p cvt_auth_val    b
     d auth_bit_t      ds                  qualified
     d   mi_aut_bit                   2a
     d   auth_val                    10a

      * *EXCLUDE, *AUTL, *USE, *CHANGE, *ALL
     d a1              ds                  qualified
     d   c                           60a   inz(
     d                                     x'00405CC5E7C3D3E4C4C54040+
     d                                     00005CC1E4E3D34040404040+
     d                                     38105CE4E2C5404040404040+
     d                                     3F105CC3C8C1D5C7C5404040+
     d                                     FF1C5CC1D3D3404040404040'
     d                                     )
     d   arr                               likeds(auth_bit_t)
     d                                     dim(5)
     d                                     overlay(c)
      * Auth constants array 2 (10 elements)
      * *OBJEXIST, *OBJMGT, *OBJOPR, *READ, *ADD, *DLT, *UPD,
      * *AUTLMGT, *EXECUTE, *OBJALTER, *OBJREF
     d a2              ds                  qualified
     d   c                          120a   inz(
     d                                     x'80005CD6C2D1C5E7C9E2E340+
     d                                     40005CD6C2D1D4C7E3404040+
     d                                     08005CD9C5C1C44040404040+
     d                                     04005CC1C4C4404040404040+
     d                                     02005CC4D3E3404040404040+
     d                                     01005CE4D7C4404040404040+
     d                                     00205CC1E4E3D3D4C7E34040+
     d                                     00105CC5E7C5C3E4E3C54040+
     d                                     00085CD6C2D1C1D3E3C5D940+
     d                                     00045CD6C2D1D9C5C6404040')
     d   arr                               likeds(auth_bit_t)
     d                                     dim(10)
     d                                     overlay(c)

     d i               s              5u 0

     d cvt_auth_val    pi
     d   mi_aut_val                   2a
     d   auth_val_lst                      likeds(auth_val_lst_t)

      /free
           // *EXCLUDE, *AUTL and system-predefined authorities:
           // *USE, *CHANGE, *ALL
           for i = 1 to 5;
               if mi_aut_val = a1.arr(i).mi_aut_bit;
                   auth_val_lst.num_auth = 1;
                   auth_val_lst.auth_val(1) =
                     a1.arr(i).auth_val;
                   return;
               endif;
           endfor;

           // Test for *OBJOPR (hex 3000)
           auth_val_lst.num_auth = 0;
           if %bitand( mi_aut_val : x'3000' ) > x'0000';
               auth_val_lst.num_auth += 1;
               auth_val_lst.auth_val(1) = '*OBJOPR';
           endif;

           // Test for 10 indivisual authorities
           for i = 1 to 10;
               if %bitand ( mi_aut_val : a2.arr(i).mi_aut_bit )
                 > x'0000';
                   auth_val_lst.num_auth += 1;
                   auth_val_lst.auth_val(auth_val_lst.num_auth) =
                     a2.arr(i).auth_val;
               endif;
           endfor;

           return;
      /end-free
     p                 e
