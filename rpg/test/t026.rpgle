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
      * @file t026.rpgle
      *
      * test of deqi()
      *
      * Dequeue a *USRQ.
      */

      /copy mih52

     d q               s               *
     d prefix          ds                  likeds(deq_prefix_t)
     /*
      * make sure the message text operand is aligned to
      * 16 bytes boundary when the target queue object
      * can contain pointers in queue entries.
      */
     d text            s             16a   inz(*all'-')
     d rtn             s             10i 0

      /free

           // resolve target *USRQ QPROC
           rslvsp_tmpl.obj_type = x'0A02';
           rslvsp_tmpl.obj_name = 'QPROC';
           rslvsp2(q : rslvsp_tmpl);

           // dequeue *USRQ QPROC
           prefix.msg_len = 16;
           rtn = deqi( %addr(prefix) : %addr(text) : q );

           if rtn = 1;
               dsply 'Q entry' '' text;
           else;
               dsply 'nothing DEQed' '';
           endif;

           *inlr = *on;
      /end-free
