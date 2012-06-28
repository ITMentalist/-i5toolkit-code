     /**
      * This file is part of i5/OS Programmer's Toolkit.
      *
      * Copyright (C) 2010, 2012  Junlei Li.
      *
      * i5/OS Programmer's Toolkit is free software: you can redistribute it and/or modify
      * it under the terms of the GNU General Public License as published by
      * the Free Software Foundation, either version 3 of the License, or
      * (at your option) any later version.
      *
      * i5/OS Programmer's Toolkit is distributed in the hope that it will be useful,
      * but WITHOUT ANY WARRANTY; without even the implied warranty of
      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      * GNU General Public License for more details.
      *
      * You should have received a copy of the GNU General Public License
      * along with i5/OS Programmer's Toolkit.  If not, see <http://www.gnu.org/licenses/>.
      */

     /**
      * @file lvlchk02.rpgle
      *
      * This program is the RPG version of ./lvlchk01.emi
      */
     h dftactgrp(*no)
      /if defined(HAVE_I5TOOLKIT)
      /copy mih-pgmexec
      /copy mih-prcthd
      /else
      * Prototype of MI instruction CALLPGMV
     d callpgmv        pr                  extproc('_CALLPGMV')
     d     pgm_ptr                     *
     d     argv                        *   dim(1) options(*varsize)
     d     argc                      10u 0 value
      * Prototype of MI instruction PCOPTR2
     d pcoptr2         pr              *   extproc('_PCOPTR2')
      /endif

     d i_main          pr                  extpgm('LVLCHK02')
     d   p_file_name                 10a
     d   p_lvlchk                     1a
     d   p_rcd_name                  10a
     d   p_rcd_id                    13a

     d @pco            s               *
     d @sept           s               *   based(@pco)
     d sept            s               *   based(@sept)
     d                                     dim(7000)
     d close_entry     c                   11
     d open_entry      c                   12
     d @ufcb           s               *   inz(%addr(ufcb))
     d                 ds
      * Fixed portion of UFCB
     d ufcb                         256a
     d file_name                     10a   overlay(ufcb:129)
     d lib_id                         5i 0 overlay(ufcb:139)
     d                                     inz(-75)
     d lib_name                      10a   overlay(ufcb:141)
     d                                     inz('*LIBL')
     d mbr_id                         5i 0 overlay(ufcb:151)
     d                                     inz(-71)
     d mbr_name                      10a   overlay(ufcb:153)
     d flags                          2a   overlay(ufcb:175)
     d                                     inz(x'8020')
      * UFCB parameters
     d lvlchk                         5i 0 overlay(ufcb:209)
     d                                     inz(6)
     d lvlonoff                       1a   overlay(ufcb:211)
     d rcdfmts                        5i 0 overlay(ufcb:212)
     d                                     inz(7)
     d maxnum                         5i 0 overlay(ufcb:214)
     d                                     inz(1)
     d curnum                         5i 0 overlay(ufcb:216)
     d                                     inz(1)
     d rcd_name                      10a   overlay(ufcb:218)
     d rcd_id                        13a   overlay(ufcb:228)
     d end_of_list                    5i 0 overlay(ufcb:241)
     d                                     inz(x'7FFF')

     d i_main          pi
     d   p_file_name                 10a
     d   p_lvlchk                     1a
     d   p_rcd_name                  10a
     d   p_rcd_id                    13a

      /free
           file_name = p_file_name; // set UFCB.file_name
           if p_lvlchk > x'00';
               lvlonoff = x'80';
               rcd_name = p_rcd_name;
               rcd_id   = p_rcd_id;
           else;
               lvlonoff = x'00';
           endif;

           // Locate PCO pointer
           @pco = pcoptr2();
           
           // Call QDMCOPEN to open the file
           callpgmv( sept(open_entry) : @ufcb : 1 );

           dsply 'DSPJOB OPTION(*OPNF) and look for:' '' p_file_name;

           // Call QDMCLOSE to close the file
           callpgmv( sept(close_entry) : @ufcb : 1 );

           *inlr = *on;
      /end-free
