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
      * @file t175.rpgle
      *
      * Extracting mapping table from MI object types to external object types.
      */

     h dftactgrp(*no)

     fQSYSPRT   o    f  132        disk

      /copy mih-comp
      /copy mih-ptr

     d rtmpl           ds                  likeds(rslvsp_tmpl)
     d                 ds
     d qlicnv                          *
     d qlicnv_ptr                      *   procptr overlay(qlicnv)
     d map_entry_t     ds                  qualified
     d   ex_type                      7a
     d   mi_type                      4a
     d spp             s               *
     d map_table       ds                  qualified
     d                                     based(spp)
     d                               32a
     d   num_ent                     10i 0
     d                               28a
     d   ent                               likeds(map_entry_t)
     d                                     dim(512)
     d i               s             10i 0
     d ws              s              1a
     d mi_type         s              4a
     d ex_type         s              7a

      /free
           // resolve system pointer to *PGM QSYS/QLICNV
           rtmpl = *allx'00';
           rtmpl.obj_type = x'0201';
           rtmpl.obj_name = 'QLICNV';
           rslvsp2 (qlicnv : rtmpl);

           // retrieve space pointer addressing the associated
           // space of QLICNV
           spp = setsppfp (qlicnv_ptr);

           for i = 1 to map_table.num_ent;
               mi_type = map_table.ent(i).mi_type;
               ex_type = map_table.ent(i).ex_type;

               except MAPREC;
           endfor;

           *inlr = *on;
      /end-free

     oQSYSPRT   e            MAPREC
     o                       mi_type
     o                       ws
     o                       ex_type
