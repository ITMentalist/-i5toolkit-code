     /**
      * This file is part of i5/OS Programmer's Toolkit.
      *
      * Copyright (C) 2010, 2011  Junlei Li.
      *
      * i5/OS Programmer's Toolkit is free software: you can
      * redistribute it and/or modify it under the terms of the GNU
      * General Public License as published by the Free Software
      * Foundation, either version 3 of the License, or (at your
      * option) any later version.
      *
      * i5/OS Programmer's Toolkit is distributed in the hope that it
      * will be useful, but WITHOUT ANY WARRANTY; without even the
      * implied warranty of MERCHANTABILITY or FITNESS FOR A
      * PARTICULAR PURPOSE.  See the GNU General Public License for
      * more details.
      *
      * You should have received a copy of the GNU General Public
      * License along with i5/OS Programmer's Toolkit.  If not, see
      * <http://www.gnu.org/licenses/>.
      */

     /**
      * @file t182.rpgle
      *
      * Test of DS ufcb_base_t, ...
      */

     h dftactgrp(*no)

      /copy ufcb
      /copy mih-prcthd
      /copy mih-pgmexec

     d rcdlen          s             10u 0
     d ufcb            ds                  qualified
     d   base                              likeds(ufcb_base_t)
     d   lvlchk                            likeds(lvlchk_parm_t)
     d   no_more                      5i 0
     d @ufcb           s               *   inz(%addr(ufcb))
     d ofa             ds                  likeds(open_fbk_t)
     d                                     based(@ofa)
     d odp             ds                  likeds(odp_t)
     d                                     based(@odp)
     d dcb             ds                  qualified
     d                                     based(@dcb)
     d   base                              likeds(dcb_t)
     d   dnl                               likeds(dnl_t)
     d                                     dim(1)
     d read_pl         ds                  likeds(io_plist_t)
     d read_optl       s              4a
     d update_pl       ds                  likeds(io_plist_t)
     d update_optl     s              4a
     d rec             s            256a   based(@dummy)
     d iofbk           ds                  likeds(io_fbk_base_t)
     d                                     based(@iofbk)

     d @pco            s               *
     d @sept           s               *   based(@pco)
     d sept            s               *   based(@sept)
     d                                     dim(7000)
     d a333_rec        ds                  qualified
     d                                     based(@a333_rec)
     d   f1                           6a
     d   f2                           6a
     d   f3                          80a
     d   f4                           8a

      /free
           ufcb = *allx'00';
           ufcb.no_more = END_PARM_LIST;
           ufcb.base.file   = 'A333';
           ufcb.base.lib_id = LIBID_LIBL38;
           ufcb.base.lib    = LIBNAM_LIBL;
           ufcb.base.mbr_id = MBRID_FIRST38;
           ufcb.base.flags  =
             %bitor(SS_PERMANENT : SS_SEC : SS_SEC_YES)
             + %bitor(OPN_INPUT : OPN_UPDATE);
           %subst(ufcb.lvlchk : 1 : 3) = NO_LVLCHK;

           // Test: rtncode=y
           ufcb.base.bang = x'80'; // @interesting ... @here 总结

           // Locate @sept
           @pco = pcoptr2();

           // Open DBF
           callpgmv( sept(sept_qcmcopen)
                   : @ufcb
                   : 1 );

           // Retrieve record length
           @ofa = ufcb.base.@open_fbk;
           rcdlen = ofa.max_rcdlen;

           // Locate IO feedback area
           @iofbk = ufcb.base.@io_fbk;

           // Locate DMEPT
           @odp = ufcb.base.@odp;
           @dcb = @odp + odp.dcb_offset;
           // dsply 'Number of DEV' '' dcb.base.num_dev;
           // dsply 'DEV name' '' dcb.dnl(1).dev_name;
             // Check DCB
             // Check DMEPT -- dcb.dnl(#)

           // Set parameter list of i/o routines
           read_pl.@ufcb = @ufcb;
           read_optl = io_opt_lst_0_get_next_wait
                  + io_opt_lst_1_get_for_update
                  + io_opt_lst_2_acc_rcd
                  + io_opt_lst_3_get;
           read_pl.@opt_lst  = %addr(read_optl);
           read_pl.@ctrl_lst = *NULL;
           update_pl.@ufcb = @ufcb;
           update_optl = io_opt_lst_0_put_wait
                  + io_opt_lst_1_get_for_read
                  + io_opt_lst_2_acc_rcd
                  + io_opt_lst_3_update;
           update_pl.@opt_lst  = %addr(update_optl);
           update_pl.@ctrl_lst = *NULL;

           @a333_rec = ufcb.base.@inbuf;
           dow '1';
               // Read a record
               callpgmv( sept(dcb.dnl(1).get_inx)
                       : read_pl.ptrs
                       : 3 );
               // @dummy = ufcb.base.@inbuf; // Check rec
               if iofbk.rec_read = 0;
                   dsply 'EOF' '';
                   leave;
               else;
                   dsply 'F4' '' a333_rec.f4;
               endif;

               // Update field F4
               callpgmv( sept(dcb.dnl(1).upd_inx)
                       : update_pl.ptrs
                       : 3 );
           enddo;

           // Close DBF
           callpgmv( sept(sept_qcmclose)
                   : @ufcb
                   : 1 );

           *inlr = *on;
      /end-free
