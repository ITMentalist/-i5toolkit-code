     /**
      * This file is part of i5/OS Programmer's Toolkit.
      *
      * Copyright (C) 2009  Junlei Li.
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
      * @file t028.rpgle
      *
      * test of matptr()
      *
      * Materialize a SYSPTR
      */

      /copy mih52

     d ptr             s               *
     d len             s             10i 0

     d tmpl_ptr        s               *
     d tmpl            ds                  likeds(matptr_tmpl_t)
     d                                     based(tmpl_ptr)

     d info_ptr        s               *
     d sysptr_info     ds                  likeds(matptr_sysptr_info)
     d                                     based(info_ptr)

      /free

           // resolve the SYSPTR addresses to myself
           rslvsp_tmpl.obj_type = x'0201';
           rslvsp_tmpl.obj_name = 'T028';
           rslvsp2(ptr : rslvsp_tmpl);

           // allocate MATPTR template buffer
           len = matptr_sysptr_info_length;
           tmpl_ptr = modasa(len);
           tmpl.bytes_in = matptr_sysptr_info_length;

           matptr(tmpl_ptr : ptr);
           info_ptr = tmpl_ptr + matptr_header_length;

           // check structure sysptr_info for returned SYSPTR info

           if tstbts(%addr(sysptr_info.ptr_target) : 0) = 1;
               // SYSPTR can be accessed from user state
               // in other words, SYSPTR is in user domain
           endif;

           *inlr = *on;
      /end-free
