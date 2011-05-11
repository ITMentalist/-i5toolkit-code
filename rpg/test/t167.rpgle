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
      * @file t167.rpgle
      *
      * Retrieve the NRL (Name Resolution List) of an MI process,
      * aka. the library list of an activate job.
      */

      /if defined(*crtbndrpg)
     h dftactgrp(*no)
      /endif

      /copy mih-comp
      /copy mih-prcthd

     d nrl_tmpl        ds                  likeds(
     d                                       matpratr_ptr_tmpl_t)
      * Option to retrieve the Name resolution list pointer
     d opt             s              1a   inz(x'18')
     d nrl_ptr         s               *
     d nrl             ds                  likeds(nrl_t)
     d                                     based(nrl_ptr)

      /free
           // retrieve the NRL space pointer
           nrl_tmpl.bytes_in = %size(matpratr_ptr_tmpl_t);
           matpratr1(nrl_tmpl : opt);

           nrl_ptr = nrl_tmpl.ptr;
           dsply 'Number of context objects in the NRL' ''
                 nrl.cnt;

           *inlr = *on;
      /end-free
