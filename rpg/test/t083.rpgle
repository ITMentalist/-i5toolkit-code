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
      * @file t083.rpgle
      *
      * Test of _RSLVDP3, _RSLVDP2.
      */
     h dftactgrp(*no)

      /copy mih-ptr
      /copy mih-pgmexec

     d spc_ptr         s               *
     d ext_data_obj    s             32a   based(spc_ptr)
     d ext_ds          ds                  qualified
     d                                     based(spc_ptr)
     d   name                        32a
     d   age                          5p 0
     d                 ds
     d proc_ptr                        *   procptr
     d dta_ptr                         *   overlay(proc_ptr)
     d ssf             s               *
     d pgm             s               *
     d dta_name        s             32a

      /free
           // [1] Test of _RSLVDP3
           // [1.1] Resolve program object T083_B
           rslvsp_tmpl.obj_type = x'0201';
           rslvsp_tmpl.obj_name = 'T083_B';
           rslvsp2(pgm : rslvsp_tmpl);

           // [1.2] Activate program T083_B
           actpg(ssf : pgm);

           // [1.3] Resolve external data object NOVEL
           dta_name = 'NOVEL';
           rslvdp3(dta_ptr : dta_name : pgm);

           // [1.4] Obtain space pointer from dta_ptr
           spc_ptr = setsppfp(proc_ptr);
           dsply 'Novel' '' ext_data_obj;

           // [2] Test of _RSLVDP2
           deactpg1(pgm);           // Deactivate PGM
           actpg(ssf : pgm);        // Activate PGM again
           dta_name = 'PERSONAL-INFO';
           // [2.1] Resolve external data object PERSEONAL-INFO
           rslvdp2(dta_ptr : dta_name);

           // Obtain space pointer from dta_ptr
           spc_ptr = setsppfp(proc_ptr);
           dsply ext_ds.name '' ext_ds.age;

           *inlr = *on;
      /end-free

     /** Example Output
      *
      *  4 > call t083
      *      DSPLY  Novel    Family, Spring, and Fall
      *      DSPLY  Sun Wukong                           1500
      */
