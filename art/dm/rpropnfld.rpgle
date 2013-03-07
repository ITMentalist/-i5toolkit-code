     /**
      * This file is part of i5/OS Programmer's Toolkit.
      *
      * Copyright (C) 2010, 2013  Junlei Li.
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
      * @file rpropnfld.rpgle
      *
      * Repaire invalid OPEN fields due to DBCS character truncation
      * in a database file.
      * - Open a database file by name dynamically
      * - Determine the record length of the opened database file
      *   member after the member is opened
      * - Read each record looply and locate the OPEN field in the
      *   read record by the input field position parameter
      * - Check for validity of the data stored in the OPEN field and
      *   repair it if the data is invalid
      *
      * @example Invoke RPROPNFLD to repaire an OPEN field in DBF
      * *LIBL/SOMEFILE at position 1, with length 10:
      * CALL RPROPNFLD('SOMEFILE  *LIBL' X'0001' X'000A')
      */

     h dftactgrp(*no)

      /copy ufcb
      /copy mih-prcthd
      /copy mih-pgmexec
      /copy mih-comp

      * DS -- Qualified object name
     d qual_obj_name_t...
     d                 ds                  qualified
     d   obj_name                    10a
     d   lib_name                    10a

      * Prototype of mine
     d i_main          pr                  extpgm('RPROPNFLD')
      * Qualified database file name
     d   fnam                              likeds(qual_obj_name_t)
      * Position of the target OPEN field
     d   fld_pos                      5u 0
      * Length of the target OPEN field
     d   fld_len                      5u 0

      * Procedure to check for (and repair) invalid OPEN data
     d check_and_repair...
     d                 pr              n

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
     d dbfiofbk        ds                  likeds(io_fbk_dbf_t)
     d                                     based(@dbfiofbk)

     d @pco            s               *
     d @sept           s               *   based(@pco)
     d sept            s               *   based(@sept)
     d                                     dim(7000)

     d @rec            s               *

     d i_main          pi
     d   fnam                              likeds(qual_obj_name_t)
     d   fld_pos                      5u 0
     d   fld_len                      5u 0

      /free
           ufcb = *allx'00';
           ufcb.no_more = END_PARM_LIST;
           ufcb.base.file   = fnam.obj_name;
           ufcb.base.lib    = fnam.lib_name;
           ufcb.base.flags  =
             SS_PERMANENT + %bitor(OPN_INPUT : OPN_UPDATE);
           // rtncode=y
           ufcb.base.rtncode = RTNCODE_YES;
           // Do NOT perform level-checking
           %subst(ufcb.lvlchk : 1 : 3) = NO_LVLCHK;

           // Locate @sept
           @pco = pcoptr2();

           // Open DBF
           callpgmv( sept(sept_qcmcopen)
                   : @ufcb
                   : 1 );

           // Retrieve record length
           @ofa = ufcb.base.@open_fbk;
           rcdlen = ofa.max_rcdlen;

           // Locate IO feedback areas
           @iofbk = ufcb.base.@io_fbk;
           @dbfiofbk = @iofbk + iofbk.spec_iofdk_offset;

           // Locate DMEPT
           @odp = ufcb.base.@odp;
           @dcb = @odp + odp.dcb_offset;

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
                  + io_opt_lst_1_get_for_read_only
                  + io_opt_lst_2_acc_rcd
                  + io_opt_lst_3_update;
           update_pl.@opt_lst  = %addr(update_optl);
           update_pl.@ctrl_lst = *NULL;

           @rec = ufcb.base.@inbuf;
           dow '1';
               // Read a record
               callpgmv( sept(dcb.dnl(1).get_inx)
                       : read_pl.ptrs
                       : 3 );
               // Check for EOF
               if iofbk.rcd_read = 0;
                   leave;
               endif;

               // Check/Repair the current record
               if check_and_repair();
                   // Update the current record
                   callpgmv( sept(dcb.dnl(1).upd_inx)
                           : update_pl.ptrs
                           : 3 );
               endif;
           enddo;

           // Close DBF
           callpgmv( sept(sept_qcmclose)
                   : @ufcb
                   : 1 );

           *inlr = *on;
      /end-free

     /**
      * Procedure to check for (and repair) invalid OPEN data
      * @pre
      *  - SPP @rec
      *  - 5U0 fld_pos
      *  - 5U0 fld_len
      *
      * @return *ON=invalid OPEN data
      */
     p check_and_repair...
     p                 b

     d @where          s               *
     d dist            s              5u 0
     d rem             s              5u 0
     d dbcs_flag       s               n   inz(*off)
     d SO              c                   x'0E'
     d SI              c                   x'0F'
     d WS              c                   x'40'
     d ctrl_ch         s              1a   inz(SO)

     d check_and_repair...
     d                 pi              n

      /free
           // Check for truncated DBCS character data
           // Search for control character SO
           @where = memchr(@rec : ctrl_ch : fld_len);
           dow @where <> *NULL and dist < fld_len;
               dist = @where - @rec;
               dbcs_flag = not dbcs_flag;

               if dbcs_flag;
                   ctrl_ch = SI;
               else;
                   ctrl_ch = SO;
               endif;
               // Search for next control character
               @where = memchr(@rec + dist : ctrl_ch : fld_len);
           enddo;

           // If dbcs_flag is still ON, there isn't truncated DBCS
           // character data.
           if not dbcs_flag;
               return *OFF;
           endif;

           // Repair truncated DBCS data
           rem = fld_len - dist - 1;
           if rem <= 2;
               propb(@rec + dist : WS : fld_len - dist);
           else;
               if %bitand(rem : x'0001') > 0; // rem is ODD
                   // Set the last character to SI
                   propb(@rec + fld_len - 1 : SI : 1);
               else;                          // rem is EVEN
                   // Set the last 2 characters to SI + x'40'
                   propb(@rec + fld_len - 2 : SI : 1);
                   propb(@rec + fld_len - 1 : WS : 1);
               endif;
           endif;

           return *ON; // Truncated DBCS data detected!
      /end-free
     p                 e
