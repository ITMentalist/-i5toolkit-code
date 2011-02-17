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
      * @file t091.rpgle
      *
      * Test of _LOCKSL2 and _UNLOCKSL2.
      *
      * @remark T091 locks at the same location in the space pointer
      *         to the SEPT object, QINSEPT. Try to call T091 from two
      *         different jobs to see the result.
      */

     h dftactgrp(*no)

      /copy mih52
     d pos             s               *
     d tmpl            ds                  likeds(
     d                                       lock_request_tmpl_ext_t)
     d                                     based(tmpl_ptr)
     d tmpl_ptr        s               *
      * space locations to lock
     d locs            s               *   based(pos)
     d                                     dim(2)
     d lock_states     s              1a   based(pos)
     d                                     dim(2)

      * LENR lock
     d an              s              1a   inz('y')

      /free
           tmpl_ptr = %alloc(80);
           propb(tmpl_ptr : x'00' : 80);
           tmpl.num_requests = 2;
           tmpl.offset_lock_state = 32 + 16 * 2; // 64
           tmpl.time_out = 20 * sysclock_one_second;
           tmpl.lock_opt = x'4000'; // 01000000,00000000

           pos = tmpl_ptr + 32;
           locs(1) = sysept();
           locs(2) = sysept() + 16;

           // specify lock states
           pos = tmpl_ptr + tmpl.offset_lock_state;
           lock_states(1) = x'09'; // LENR lock on locs(1)
           lock_states(2) = x'11'; // LEAR lock on locs(2)

           locksl2(tmpl);

           dsply 'space locations locked.' '' an;

           unlocksl2(tmpl_ptr);
           dealloc tmpl_ptr;
           *inlr = *on;
      /end-free
