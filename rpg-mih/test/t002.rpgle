     /**
      * This file is part of i5/OS Programmer's Toolkit.
      * 
      * Copyright (C) 2009  Junlei Li.
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
      * @file t002.rpgle
      *
      * test of andcstr
      */

      /copy mih52
     d str1            s              8a
     d str2            s              8a
     d result          s              8a

      /free

          str1 = x'69';  // 01101001        
          str2 = x'91';  // 10010001        
          andcstr(result : str1 : str2 : 1); // 01101000, x'68'
          dsply 'result' '' result;         

          *inlr = *on;
      /end-free
