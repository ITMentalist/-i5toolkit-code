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
      * @file t171.rpgle
      *
      * Test of _MATDMPS. This program materialize attributes of a
      * dump space object (with MI object type code hex 13) which is a
      * component of a given save file. The only parameter accepted by
      * t171.rpgle is a CHAR(10) object name of an FILE object with
      * attribute SAVF.
      *
      * @remark Since both a *FILE object and a dump space object are
      * in the system domain. This program can run only under security
      * level 30 or bellow.
      */

     h dftactgrp(*no)

      /copy mih-comp
      /copy mih-ptr
      /copy mih-dmps

     d i_main          pr                  extpgm('T171')
     d   savf_name                   10a

     d rtmpl           ds                  likeds(rslvsp_tmpl)
     d                 ds
     d file                            *
     d pfile                           *   overlay(file) procptr
     d spp             s               *
     d dmps_offset     s              5u 0 inz(x'0280')
     d dmps            s               *   based(spp)
     d mat_tmpl        ds                  likeds(matdmps_t)
     d bytes           s             10u 0
     d nomax           s              6a   inz('*NOMAX')

     d i_main          pi
     d   savf_name                   10a

      /free
           // resolve system pointer to target *FILE object (hex 1901 space object)
           rtmpl = *allx'00';
           rtmpl.obj_type = x'1901';
           rtmpl.obj_name = savf_name;
           rslvsp2 (file : rtmpl);

           spp = setsppfp(pfile);
           spp = spp + dmps_offset;

           // materialize attributes of target dump space object
           mat_tmpl = *allx'00';
           mat_tmpl.bytes_in = %size(matdmps_t);
           matdmps(mat_tmpl : dmps);

           // report materialization result
           bytes = mat_tmpl.size * 512;
           dsply 'Dump space size' '' bytes;

           bytes = mat_tmpl.data_size * 512;
           dsply 'Data size' '' bytes;

           if mat_tmpl.data_size_limit = 0;
               dsply 'Data size limit' '' nomax;
           else;
               bytes = mat_tmpl.data_size_limit * 512;
               dsply 'Data size limit' '' bytes;
           endif;

           *inlr = *on;
      /end-free
