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
      * @file t181.rpgle
      *
      * Test of MATRMD -- Retrieve amount of unallocated pool storage.
      */

     h dftactgrp(*no)

      /copy mih-stgrsc

     d @tmpl           s               *
     d tmpl            ds                  likeds(matrmd_tmpl2d_t)
     d                                     based(@tmpl)
     d @mspe           s               *
     d mspe            ds                  likeds(msp_info2_t)
     d                                     based(@mspe)
     d opt             ds                  likeds(matrmd_option_t)
     d len             s             10u 0
     d num             s             10u 0
     d unal            s             20u 0

      /free
           opt = *allx'00';
           opt.val = x'2D';
           // Get length of necessary buffer
           @tmpl = %alloc(%size(matrmd_tmpl2d_t));
           tmpl.bytes_in = %size(matrmd_tmpl2d_t);
           matrmd(tmpl : opt);
           len = tmpl.bytes_out;

           // Allocate buffer for materialization template
           @tmpl = %realloc(@tmpl : len);
           tmpl.bytes_in = len;
           // Actually materialize main storage pool info
           matrmd(tmpl : opt);

           // Report amount of unallocated pool storage in each MSP
           @mspe = @tmpl + %size(matrmd_tmpl2d_t);
           num = 1;
           dow num <= tmpl.current_number_of_pools
               and
               mspe.pool_size > 0; // Ignore empty pools
               // Amount of unallocated pool storage in 1KB units
               unal = mspe.unal
                      * tmpl.machine_minimum_transfer_size
                      / 1024;
               dsply num '' unal;

               // Offset to next msp_info2_t structure
               num += 1;
               @mspe += %size(msp_info2_t);
           enddo;

           dealloc @tmpl;
           *inlr = *on;
      /end-free
