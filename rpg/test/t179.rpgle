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
      * @file t179.rpgle
      *
      * Test of _LUWRKA: retrieve the Controlled Cancel field.
      */

     h dftactgrp(*no)

      /if defined(HAVE_I5TOOLKIT)
      /copy mih-pgmexec
     d luwa            ds                  likeds(luwa_t)
     d                                     based(spp)
      /else
      * Prototype type of system BIF _LUWRKA
     d luwrka          pr              *   extproc('_LUWRKA')
     d luwa            ds                  qualified
     d                                     based(spp)
     d   ctrl_cancel                  1a   overlay(luwa:17)
      /endif
     d spp             s               *

      /free
           spp = luwrka();
           dsply 'End Status' '' luwa.ctrl_cancel;
             // To change the current value of the Controlled Cancel
             // field, type a character and then type enter.

           *inlr = *on;
      /end-free
