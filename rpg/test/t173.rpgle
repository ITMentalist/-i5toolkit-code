     /**
      * This file is part of i5/OS Programmer's Toolkit.
      * 
      * Copyright (C) 2010, 2011  Junlei Li.
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
      * @file t173.rpgle
      *
      * Test of _CVTTS (Convert Timestamp). This example convert an
      * input 8-byte system clock to an SAA timestamp.
      */

     h dftactgrp(*no)

      /copy mih-dattim

     d i_main          pr                  extpgm('T173')
     d   sys_clock                    8a

     d tmpl            ds                  likeds(convert_dattim_t)
     d saa_ts          s             26a

     d i_main          pi
     d   sys_clock                    8a

      /free

           tmpl = *allx'00';
           tmpl.size = %size(tmpl);
           tmpl.op1_ddat_num = 1;
           tmpl.op2_ddat_num = 2;
           tmpl.op1_len      = 26; // SAA timestamp
           tmpl.op2_len      = 8;  // system clock
           tmpl.ddat_list_len= 256;
           tmpl.ddats        = 2;
           tmpl.off_ddat1    = 24;
           tmpl.off_ddat2    = 140;
           tmpl.ddat1        = saa_timestamp_ddat_value;
           tmpl.ddat2        = system_clock_ddat_value;

           cvtts( saa_ts
                : sys_clock
                : tmpl );
           dsply 'SAA timestamp' '' saa_ts;

           *inlr = *on;
      /end-free
