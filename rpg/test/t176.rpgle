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
      * @file t176.rpgle
      *
      * Reallocate heap storage on the default heap space of an AGP.
      */

     h dftactgrp(*no)

      /copy mih-heap
     d spp             s               *
     d c16             s             16a   based(spp)
     d c32             s             32a   based(spp)

      /free
           spp = alchss(0 : 16);
           c16 = *all'-';
           dsply '16 bytes' '' c16;

           spp = realchss(spp : 32);
           c32 = *all'=';
           dsply '32 bytes' '' c32;

           frehss(spp);
           *inlr = *on;
      /end-free
