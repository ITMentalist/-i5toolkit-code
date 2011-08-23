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
      * @file enq007.rpgle
      *
      * This program calls MIPORTAL to enqueue a message onto a USRQ, *LIBL/Q007.
      */

     d rt              ds                  qualified
     d   obj_type                     2a   inz(x'0A02')
     d   obj_name                    30a   inz('Q007')
     d   req_auth                     2a   inz(*allx'00')

      * instruction index=3, _RSLVSP2
     d inx             s              5u 0 inz(3)
     d q               s             16a
     d enq_prefix      ds                  qualified
     d   msg_len                     10i 0
     d msg             s             32a   inz('from enq.rpgle')

     c                   call      'MIPORTAL'
     c                   parm                    inx
     c                   parm                    q
     c                   parm                    rt
     c     'SYP to Q'    dsply                   q

      * instruction index=4, ENQ
     c                   eval      inx = 4
     c                   eval      enq_prefix.msg_len =
     c                               %len(%trimr(msg))
     c                   call      'MIPORTAL'
     c                   parm                    inx
     c                   parm                    q
     c                   parm                    enq_prefix
     c                   parm                    msg

     c                   seton                                        lr
