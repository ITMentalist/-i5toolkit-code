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
      * @file t172.rpgle
      *
      * Materializing all context objects in the Machine Context
      */

     h dftactgrp(*no)

     fQSYSPRT   o    f  132        disk

      /copy mih-comp
      /copy mih-ptr
      /copy mih-pgmexec
      /copy mih-ctx
      /copy mih-undoc

     d rtmpl           ds                  likeds(rslvsp_tmpl)
     d mopt            ds                  likeds(matctx_option_t)
     d mtmpl           ds                  likeds(
     d                                     matctx_receiver_ext_t)
     d                                     based(tmpl_ptr)
     d tmpl_ptr        s               *
     d o               s             10a   inz('*MCHCTX')
     d ent             ds                  likeds(
     d                                     context_entry_full_t)
     d                                     based(ent_ptr)
     d ent_ptr         s               *
     d pos             s             10i 0
     d num             s              5s 0
     d ws              s              1a
     d cvtlen          s             10i 0 inz(4)
     d obj_type        s              4a
     d sls_addr        s             16a
     d                 ds
     d ctx_syp                         *
     d hex_addr                       8a   overlay(ctx_syp:9)

      /free

           mopt = *allx'00';
           setbts(%addr(mopt.sel_flag) : 4);
             // materialize extended context attributes
           setbts(%addr(mopt.sel_flag) : 6);
           setbts(%addr(mopt.sel_flag) : 7);
             // return symbolic ID and syp of context entries
           mopt.sel_criteria = x'41'; // materialize the system machine context by MI object type (including hidden ctx)
           mopt.obj_type = x'04';     // materialize context objects in the system machine context

           tmpl_ptr = modasa(x'080000');
           mtmpl = *allx'00';
           mtmpl.base.bytes_in = x'080000';
           QusMaterializeContext(mtmpl : *null : mopt);

           pos = %size(matctx_receiver_ext_t);
           ent_ptr = tmpl_ptr + pos;
           num = 1;
           dow pos < mtmpl.base.bytes_out;
               exsr cvtobjtyp;
               exsr cvtaddr;
               except CTXREC;

               pos += 48;
               ent_ptr += 48;
               num += 1;
           enddo;

           // mtmpl.ext_attr: hex 00
           if tstbts(%addr(mtmpl.ext_attr) : 0) > 0;
               dsply 'Has Changed List' '' o;
           endif;

           if tstbts(%addr(mtmpl.ext_attr) : 1) = 0;
               dsply 'Changed List Usable' '' o;
           endif;

           if tstbts(%addr(mtmpl.ext_attr) : 2) > 0;
               dsply 'Protected from Changes' '' o;
           endif;

           if tstbts(%addr(mtmpl.ext_attr) : 3) > 0;
               dsply 'Context is hidden' '' o;
           endif;

           *inlr = *on;
      /end-free

     c     cvtobjtyp     begsr
     c                   eval      cvtlen = 4
     c                   call      'CVTHC'
     c                   parm                    obj_type
     c                   parm                    ent.type
     c                   parm                    cvtlen
     c                   endsr

     c     cvtaddr       begsr
     c                   eval      ctx_syp = ent.ptr
     c                   eval      cvtlen = 16
     c                   call      'CVTHC'
     c                   parm                    sls_addr
     c                   parm                    hex_addr
     c                   parm                    cvtlen
     c                   endsr

     oQSYSPRT   e            CTXREC
     o                       num
     o                       ws
     o                       obj_type
     o                       ws
     o                       ent.name
     o                       ws
     o                       sls_addr
