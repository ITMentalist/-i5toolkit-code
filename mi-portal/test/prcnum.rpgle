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
      * @file prcnum.rpgle
      *
      * Test of MI Portal:
      *  - materializing number of installed processors by issuing
      *    MATMATR with option hex 01DC
      */

     d tmpl            ds                  qualified
     d     bi                        10i 0 inz(10)
     d     bo                        10i 0
     d     prc_num                    5u 0

     d opt             s              2a   inz(x'01DC')
     d ent_num         s              5u 0 inz(1)

     c                   call      'MIPORTAL'
     c                   parm                    ent_num
     c                   parm                    tmpl
     c                   parm                    opt
     c     'Processors'  dsply                   tmpl.prc_num
     c                   seton                                        lr
