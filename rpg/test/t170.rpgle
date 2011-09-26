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

     d i_main          pr                  extpgm('T170')
     d   p_ctx_name                  10a

     d rtmpl           ds                  likeds(rslvsp_tmpl)
     d mopt            ds                  likeds(matctx_option_t)
     d mtmpl           ds                  likeds(
     d                                     matctx_receiver_ext_t)
     d                 ds
     d ctx                             *
     d ctx2                            *   overlay(ctx)
     d                                     procptr

     d i_main          pi
     d   p_ctx_name                  10a

      /free
           // resolve system pointer to target context object
           rtmpl = *allx'00';
           rtmpl.obj_type = x'0401';
           rtmpl.obj_name = p_ctx_name;
           rslvsp2 (ctx : rtmpl);

           //
           mopt = *allx'00';
           setbts(%addr(mopt.sel_flag) : 4);
             // materialize extended context attributes
           mtmpl = *allx'00';
           mtmpl.base.bytes_in = %size(matctx_receiver_ext_t);
           QusMaterializeContext(mtmpl : ctx2 : mopt);
           // check mtmpl.ext_attr
           if tstbts(%addr(mtmpl.ext_attr) : 0) > 0;
               dsply 'Has Changed List' '' p_ctx_name;
           endif;

           if tstbts(%addr(mtmpl.ext_attr) : 1) = 0;
               dsply 'Changed List Usable' '' p_ctx_name;
           endif;

           if tstbts(%addr(mtmpl.ext_attr) : 2) > 0;
               dsply 'Protected from Changes' '' p_ctx_name;
           endif;

           if tstbts(%addr(mtmpl.ext_attr) : 3) > 0;
               dsply 'Context is hidden' '' p_ctx_name;
           endif;

           *inlr = *on;
      /end-free
