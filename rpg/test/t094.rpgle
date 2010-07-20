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
      * @file t094.rpgle
      *
      * Test of _MATPRLK1 .
      */

     h dftactgrp(*no)

      /copy mih52
     d tmpl_ptr        s               *
     d tmpl            ds                  likeds(matprlk_tmpl_t)
     d                                     based(tmpl_ptr)
     d pos             s               *
     d lockd           ds                  likeds(matprlk_lock_desc_t)
     d                                     based(pos)
     d TMPL_LEN        c                   4096
     d ind             s              5i 0

      /free
           // allocate materialization template
           tmpl_ptr = %alloc(TMPL_LEN);
           propb(tmpl_ptr : x'00' : TMPL_LEN);
           tmpl.bytes_in = TMPL_LEN;

           // materialize process locks
           matprlk1 (tmpl);

           // check process locks
           pos = tmpl_ptr + matprlk_lockd_offset;
           for ind = 1 to tmpl.num_lockd;
               // object or space location on which a
               // process lock is allocated.

               // lock type
               pos += matprlk_lockd_length;
           endfor;

           dealloc tmpl_ptr;
           *inlr = *on;
      /end-free
