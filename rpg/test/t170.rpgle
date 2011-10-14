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
      * @file t170.rpgle
      *
      * Test of _MATCTX2.
      */

     h dftactgrp(*no)

      /copy mih-comp
      /copy mih-ptr
      /copy mih-pgmexec
      /copy mih-ctx
      /copy mih-undoc

     d i_main          pr                  extpgm('T170')
     d   p_ctx_name                  10a

     d cvt_saa_ts      pr
     d   saa_ts                      26a
     d   sys_clock                    8a

     d rtmpl           ds                  likeds(rslvsp_tmpl)
     d mopt            ds                  likeds(matctx_option_t)
     d mtmpl           ds                  likeds(
     d                                     matctx_receiver_ext_t)
     d                 ds
     d ctx                             *
     d ctx2                            *   overlay(ctx)
     d                                     procptr
     d ctx3                          16a   overlay(ctx)
     d cur_ts          s             26a

     d i_main          pi
     d   p_ctx_name                  10a

      /free
           if p_ctx_name = 'QTEMP';
               ctx = qtempptr();
           else;
               // resolve system pointer to target context object
               rtmpl = *allx'00';
               rtmpl.obj_type = x'0401';
               rtmpl.obj_name = p_ctx_name;
               rslvsp2 (ctx : rtmpl);
           endif;

           //
           mopt = *allx'00';
           setbts(%addr(mopt.sel_flag) : 4);
             // materialize extended context attributes
           mtmpl = *allx'00';
           mtmpl.base.bytes_in = %size(matctx_receiver_ext_t);
           QusMaterializeContext(mtmpl : ctx2 : mopt);
           // check mtmpl.ext_attr
           if tstbts(%addr(mtmpl.ext_attr) : 0) > 0;
               dsply 'Has COL' '' p_ctx_name;
               cvt_saa_ts(cur_ts : mtmpl.col_time);
               dsply 'COL time' '' cur_ts;

               if tstbts(%addr(mtmpl.ext_attr) : 1) = 0;
                   dsply 'COL Usable' '' p_ctx_name;
               endif;
           endif;

           if tstbts(%addr(mtmpl.ext_attr) : 2) > 0;
               dsply 'Protected from Changes' '' p_ctx_name;
           endif;

           if tstbts(%addr(mtmpl.ext_attr) : 3) > 0;
               dsply 'Context is hidden' '' p_ctx_name;
           endif;

           *inlr = *on;
      /end-free

     p cvt_saa_ts      b

      /copy mih-dattim
     d tmpl            ds                  likeds(convert_dattim_t)

     d cvt_saa_ts      pi
     d   saa_ts                      26a
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
      /end-free
     p                 e
