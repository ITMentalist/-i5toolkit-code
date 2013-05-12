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
      * @file t157b.rpgle
      *
      * Test of _NPMPARMLISTADDR:
      * Retrieve plist passed to the "PEP" procedure of an ILE pgm.
      * @remark Obviously the main procedure of a user ILE pgm
      *         is NOT the actual PEP procedure of the pgm.
      *
      * To test T157B, call it like the following:
      * CALL T157B ('AAAA...' 'BBB...' 'CCC...')
      */

     h dftactgrp(*no)

      /copy mih-pgmexec

     d plist_ptr       s               *
     d plist           ds                  likeds(npm_plist_t)
     d                                     based(plist_ptr)

     d ppp             pr                  extpgm('T157B')
     d   x1                           1a
     d   x2                           1a
     d                                1a
     d                                1a
      * ... until x256
     d ppp             pi
     d   x1                           1a
     d   x2                           1a
     d   x3                           1a
     d   x4                           1a
      * ... until x256
     d parm_desc_list  ds                  likeds(parm_desc_list_t)
     d                                     based(@parm_desc_list)
     d argc            s             10u 0
      * Parameters passed to a program is in form of an array
      * of space pointer.
     d argv            s               *   dim(256)
     d                                     based(@argv)
     d i               s             10u 0
     d @arg            s               *
     d arg_val         s              8a   based(@arg)

      /free
           plist_ptr = npm_plist();

           // argc (number of parameters passed)
           @parm_desc_list = plist.parm_desc_list;
           argc = parm_desc_list.argc;
           dsply 'argc' '' argc;

           // argv
           @argv = %addr(plist.argvs);
           for i = 1 to argc;
               @arg = argv(i);
               dsply i '' arg_val;
           endfor;

           *inlr = *on;
      /end-free
