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
      * @file t070.rpgle
      *
      * Test of recursive locks via CHKLKVAL/CLRLKVAL.
      */
     h dftactgrp(*no)

      /copy mih54
     d lck             s             20i 0
     d f               pr
     d     old_val                   20i 0 value
     d     new_val                   20i 0 value

      /free
           f(0 : 1);
           *inlr = *on;
      /end-free

     p f               b
     d f               pi
     d     old_val                   20i 0 value
     d     new_val                   20i 0 value
      /free
           chklkval(lck : old_val : new_val);
           if new_val > 5;                     // max recursion depth
               return;
           else;
               f(old_val + 1 : new_val + 1);
           endif;
           clrlkval(lck : old_val);
      /end-free
     p f               e
