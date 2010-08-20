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
      * @file t103.rpgle
      *
      * Test of _MATINV.
      */

     h dftactgrp(*no)

      /copy mih52
     d tmpl            ds                  likeds(matinv_npm_tmpl_t)
     d sel             ds                  likeds(matinv_selection_t)
     d
     d

      /free
           tmpl.bytes_in = matinv_npm_tmpl_length;
           sel = *allx'00';
           sel.inv_num = 1;

           matinv(tmpl : sel);
             // check tmpl

           *inlr = *on;
      /end-free