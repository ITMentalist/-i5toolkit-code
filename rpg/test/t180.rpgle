     /**
      * This file is part of i5/OS Programmer's Toolkit.
      *
      * Copyright (C) 2010, 2011  Junlei Li.
      *
      * i5/OS Programmer's Toolkit is free software: you can
      * redistribute it and/or modify it under the terms of the GNU
      * General Public License as published by the Free Software
      * Foundation, either version 3 of the License, or (at your
      * option) any later version.
      *
      * i5/OS Programmer's Toolkit is distributed in the hope that it
      * will be useful, but WITHOUT ANY WARRANTY; without even the
      * implied warranty of MERCHANTABILITY or FITNESS FOR A
      * PARTICULAR PURPOSE.  See the GNU General Public License for
      * more details.
      *
      * You should have received a copy of the GNU General Public
      * License along with i5/OS Programmer's Toolkit.  If not, see
      * <http://www.gnu.org/licenses/>.
      */

     /**
      * @file t180.rpgle
      *
      * Retrieve problem phase program.
      */

     h dftactgrp(*no)

      /copy mih-prcthd
      /copy mih-mchobs

     d pratr           ds                  likeds(matpratr_ptr_tmpl_t)
     d objatr          ds                  likeds(matsobj_tmpl_t)
     d opt             s              1a   inz(x'1B')
     d ppp             s             21a

      /free
           matpratr1(pratr : opt);
           matsobj(objatr : pratr.ptr);
           ppp = %trim(objatr.ctx_name) +
                 '/' +
                 %trim(objatr.obj_name);
           dsply 'Problem phase program'
                 ''
                 ppp;
           *inlr = *on;
      /end-free
