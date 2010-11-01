     /**
      * This file is part of i5/OS Programmer's Toolkit.
      *
      * Copyright (C) 2010  Junlei Li.
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
      * @file t136.rpgle
      *
      * Test of QusMaterializeContext.
      */

     h dftactgrp(*no)

      /copy mih52
     d opt             ds                  likeds(matctx_option_t)
     d rcv             ds                  likeds(matctx_receiver_t)
     d                                     based(bufptr)
     d bufptr          s               *
     d objd            ds                  likeds(context_entry_full_t)
     d                                     based(pos)
     d pos             s               *
     d len             s             10i 0
     d num             s             10i 0
     d i               s             10i 0
     d                 ds
     d ctx                             *
     d ctx2                            *   procptr overlay(ctx)

      /free
           rslvsp_tmpl.obj_type = x'0401';
           rslvsp_tmpl.obj_name = 'LSBIN';
           rslvsp2(ctx : rslvsp_tmpl);

           opt = *allx'00';
           opt.sel_flag = x'07';
           opt.sel_criteria = x'40';

           bufptr = modasa(8);
           rcv.bytes_in = 8;
           QusMaterializeContext(rcv : ctx2 : opt);

           len = rcv.bytes_out;
           bufptr = modasa(len);
           rcv.bytes_in = len;
           QusMaterializeContext(rcv : ctx2 : opt);

           // check materialized contex entries
           pos = bufptr + 96;
           // check objd
           num = (rcv.bytes_out - 96) / %size(objd);
           for i = 1 to num;
               dsply i '' objd.objid.name;
               if objd.objid.name = 'q';
                   leave;
               endif;

               pos += %size(objd);
           endfor;

           *inlr = *on;
      /end-free
