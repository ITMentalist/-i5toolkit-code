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
      * @file t174.rpgle
      *
      * List changed object list of a library after the last full save.
      */

     h dftactgrp(*no) bnddir('QC2LE')

     fQSYSPRT   o    f  132        disk

      /copy mih-comp
      /copy mih-ptr
      /copy mih-pgmexec
      /copy mih-ctx
      /copy mih-undoc

     d i_main          pr                  extpgm('T174')
     d   p_ctx_name                  10a

     d prt_chg_obj     pr
     d   bytes                       10i 0
     d   mod_ts                       8a

     d rtmpl           ds                  likeds(rslvsp_tmpl)
     d mopt            ds                  likeds(matctx_option_t)
     d mtmpl           ds                  likeds(
     d                                       matctx_receiver_ext_t)
     d                 ds
     d ctx                             *
     d ctx2                            *   overlay(ctx)
     d                                     procptr
     d col_time        s             26a
     d num_chg         s             10i 0
      * output fields
     d obj_num         s              5s 0
     d ws              s              1a
     d obj_type        s             25a
     d obj_name        s             30a

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

           // retrieve current time of the COL
           mopt = *allx'00';
           setbts(%addr(mopt.sel_flag) : 4);
             // materialize extended context attributes
           mtmpl = *allx'00';
           mtmpl.base.bytes_in = %size(matctx_receiver_ext_t);
           QusMaterializeContext(mtmpl : ctx2 : mopt);

           if tstbts(%addr(mtmpl.ext_attr) : 0) = 0
              or
              tstbts(%addr(mtmpl.ext_attr) : 1) > 0;
                 dsply 'No usable COL' '' p_ctx_name;
                 *inlr = *on;
                 return;
           endif;

           // retrieve changed context entries
           mopt = *allx'00';
           setbts(%addr(mopt.sel_flag) : 7); // retrieve symbolic ID
           setbts(%addr(mopt.sel_criteria) : 3);
             // select by modification date/time
           mopt.timestamp = mtmpl.col_time;
             // use current COL time as search criteria
           mtmpl = *allx'00';
           mtmpl.base.bytes_in = %size(matctx_receiver_t);
           QusMaterializeContext(mtmpl : ctx2 : mopt);

           num_chg = (mtmpl.base.bytes_out - %size(matctx_receiver_t))
             / %size(sym_object_id_t); // (bytes_out - 96) / 32
           if num_chg > 0;
               dsply 'Number of changed objects' '' num_chg;
           else;
               dsply 'No changed objects in' '' p_ctx_name;
               *inlr = *on;
               return;
           endif;

           prt_chg_obj(mtmpl.base.bytes_out : mopt.timestamp);

           *inlr = *on;
      /end-free

     oQSYSPRT   e            CHGOBJREC
     o                       obj_num
     o                       ws
     o                       obj_type
     o                       ws
     o                       obj_name

     p prt_chg_obj     b

      /copy apiec

     d qlicvttp        pr                  extpgm('QLICVTTP')
     d   cvt_type                    10a   options(*varsize)
     d   ext_type                    10a
     d   mi_type                      2a
     d   ec                                likeds(qusec_t)

     d cvthc           pr                  extproc('cvthc')
     d                                1a   options(*varsize)
     d                                1a   options(*varsize)
     d                               10i 0 value

     d mopt            ds                  likeds(matctx_option_t)
     d mtmpl           ds                  likeds(matctx_receiver_t)
     d                                     based(tmpl_ptr)
     d tmpl_ptr        s               *
     d oid             ds                  likeds(sym_object_id_t)
     d                                     based(pos)
     d pos             s               *
     d i               s             10i 0
     d cvt_type        s             10a   inz('*HEXTOSYM')
     d mi_type         s              4a
     d ec              ds                  likeds(qusec_t)

     d prt_chg_obj     pi
     d   bytes                       10i 0
     d   mod_ts                       8a

      /free
           tmpl_ptr = %alloc(bytes);

           // retrieve changed context entries
           mopt = *allx'00';
           setbts(%addr(mopt.sel_flag) : 7); // retrieve symbolic ID
           setbts(%addr(mopt.sel_criteria) : 3);
             // select by modification date/time
           mopt.timestamp = mod_ts;
             // use current COL time as search criteria
           mtmpl = *allx'00';
           mtmpl.bytes_in = bytes;
           QusMaterializeContext(mtmpl : ctx2 : mopt);

           num_chg = (mtmpl.bytes_out - %size(matctx_receiver_t))
             / %size(sym_object_id_t); // (bytes_out - 96) / 32

           pos = tmpl_ptr + %size(matctx_receiver_t);
           ec.bytes_in = %size(ec);
           for i = 1 to num_chg;
               obj_num = i;
               // convert returned MI object type code to external objec type name
               obj_type = *blanks;
               qlicvttp(cvt_type : obj_type : oid.type : ec);
               // in case QLICVTTP failed on internal obj types, e.g. hex 0D50 (*MEM)
               if ec.bytes_out > 0;
                   cvthc(mi_type : oid.type : 4);
                   obj_type = 'MI Type Code: hex ' + mi_type;
               endif;
               obj_name = oid.name;
               except CHGOBJREC;

               pos += %size(sym_object_id_t); // 32
           endfor;

           dealloc tmpl_ptr;
      /end-free
     p                 e
