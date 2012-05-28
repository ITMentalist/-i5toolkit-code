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
      * @file t178.rpgle
      *
      * Test of _MATSOBJ. This program retrieves the creation
      * timestamp and the last-modified timestamp of a given MI
      * object.
      *
      * @remark Note that issuing MATSOBJ instruction on an MI object
      * in the System domain at security level 40 or above will always
      * raise an Object Domain Violation (hex 4401) exception.
      */

     h dftactgrp(*no)

      /copy mih-ptr
      /copy mih-mchobs
      /copy mih-dattim

     d i_main          pr                  extpgm('T178')
     d   obj_type                     2a
     d   obj_name                    30a

     d cvt_saa_ts      pr            26a
     d   sys_clock                    8a

     d tmpl            ds                  likeds(matsobj_tmpl_t)
     d obj             s               *
     d saa_ts          s             26a

     d i_main          pi
     d   obj_type                     2a
     d   obj_name                    30a

      /free
           rslvsp_tmpl.obj_type = obj_type;
           rslvsp_tmpl.obj_name = obj_name;
           rslvsp2(obj : rslvsp_tmpl);

           tmpl = *allx'00';
           tmpl.bytes_in = %size(tmpl);
           matsobj(tmpl : obj);

           saa_ts = cvt_saa_ts(tmpl.crt_ts);
           dsply 'Creation timestamp' '' saa_ts;
           saa_ts = cvt_saa_ts(tmpl.mod_ts);
           dsply 'Last-modify timestamp' '' saa_ts;

           *inlr = *on;
      /end-free

     p cvt_saa_ts      b

      /copy mih-dattim
     d tmpl            ds                  likeds(convert_dattim_t)
     d saa_ts          s             26a

     d cvt_saa_ts      pi            26a
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

           return saa_ts;
      /end-free
     p                 e
