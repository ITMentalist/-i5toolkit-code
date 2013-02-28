     /**
      * @file autbits03.rpgle
      */

     h dftactgrp(*no)
      * Authority value list DS
     d auth_val_lst_t  ds                  qualified
     d   num_auth                     5u 0
     d   auth_val                    10a   dim(11)
      * Convert MI authority bits to authority special values
     d cvt_auth_val    pr                  extproc('cvt_auth_val')
     d   mi_aut_val                   2a
     d   auth_val_lst                      likeds(auth_val_lst_t)

     d miaut           s              2a   inz(x'DF18')
     d autlst          ds                  likeds(auth_val_lst_t)

      /free
           cvt_auth_val( miaut : autlst);
           *inlr = *on;
      /end-free

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
