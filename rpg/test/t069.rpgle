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
      * @file t069.rpgle
      *
      * test of CTD
      * @todo MCH5601 ?!
      */
     h dftactgrp(*no)

      /copy mih52

      * user code
     d tmpl            ds                  likeds(
     d                                       dt_compute_duration_tmpl_t)
     d                                     based(tmpl_ptr)
     d tmpl_ptr        s               *
     d tmpl_len        s              5u 0
     d offset          s              5u 0
     d ddat_ptr        s               *
     d ddat1           ds                  likeds(saa_ddat1_t)
     d                                     based(ddat_ptr)
     d ddat2           ds                  likeds(saa_ddat1_t)
     d                                     based(ddat_ptr)

      * ISO time
     d morning         s             10a   inz('07.50.11')
     d evening         s             10a   inz('09.11.12')
     d dur             s              6p 0

      /free
           // allocate storage for instruction template
           tmpl_len = datetime_ddat_list_offset
                      + 16
                      + (4 + saa_ddat1_len)   // DDAT for op1
                      + (4 + saa_ddat1_len) ; // DDATs for op2, 3
           tmpl_ptr = %alloc(tmpl_len) ;

           // init instruction template
           tmpl.tmpl_size = tmpl_len ;
           tmpl.op1_ddat_index = 1   ;
           tmpl.op2_ddat_index = 2   ;
           tmpl.op3_ddat_index = 2   ;
           tmpl.op2_length     = 8   ;
           tmpl.op3_length     = 8   ;
           tmpl.ddat_list_len  = 16 + 2 * 4
             + saa_ddat1_len
             + saa_ddat1_len   ; // length of entire DDAT list
           tmpl.ddats          = 2   ;

           // init DDATs
           offset = 16 + 2 * 4 ; // start from the beginning of DDAT list
           tmpl.ddat_offsets(1) = offset ;
           ddat_ptr = tmpl_ptr
             + datetime_ddat_list_offset + offset  ;
           propb(ddat_ptr : x'00' : saa_ddat1_len) ;
           ddat1.fmt_code = x'0015'      ; // time duration

           offset += saa_ddat1_len       ;
           tmpl.ddat_offsets(2) = offset ;
           ddat_ptr = tmpl_ptr
             + datetime_ddat_list_offset + offset  ;
           propb(ddat_ptr : x'00' : saa_ddat1_len) ;
           ddat2.fmt_code = x'0004'      ; // ISO time
           ddat2.time_sep = '.'          ;
           ddat2.hour_time_zone = 24     ;
           ddat2.minute_time_zone = 60   ;

           cdd(%addr(dur) : %addr(evening) : %addr(morning) : tmpl) ;
           dsply 'durantion' '' dur;
             // DSPLY  durantion ?

           dealloc tmpl_ptr     ;
           *inlr = *on;
      /end-free
