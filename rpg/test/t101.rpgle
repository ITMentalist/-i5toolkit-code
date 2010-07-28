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
      * @file t101.rpgle
      *
      * Test of _MATINVS2.
      * Meterialize the call stack of the current thread.
      */
     h dftactgrp(*no)

      /copy mih52
     d len             s             10i 0
     d ptr             s               *
     d pos             s               *
     d tmpl            ds                  likeds(matinvs_tmpl_t)
     d                                     based(ptr)
     d inve            ds                  likeds(invocation_entry_t)
     d                                     based(pos)
     d i               s             10i 0

      /free
           ptr = %alloc(min_matinvs_tmpl_length);
           tmpl.bytes_in = min_matinvs_tmpl_length;
           matinvs2(tmpl);

           len = tmpl.bytes_out;
           ptr = %realloc(ptr : len);
           tmpl.bytes_in = len;
           matinvs2(tmpl);

           // check each call stack entry
           pos = ptr + min_matinvs_tmpl_length;
           for i = 1 to tmpl.entries;
               //

               pos += invocation_entry_length;
           endfor;

           dealloc ptr;
           *inlr = *on;
      /end-free
