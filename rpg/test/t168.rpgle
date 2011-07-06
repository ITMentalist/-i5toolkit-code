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
      * @file t168.rpgle
      *
      * Test of the queue object APIs
      */

      /copy q-api
     d q_name          s             20a   inz('E006      *LIBL')
      * *LIBL/E006 is a pre-created *USRQ
     d subtype         s              1a   inz(x'02')
     d key_len         s             10i 0 inz(9)
     d key             s              9a
     d msg_len         s             10i 0 inz(17)
     d msg             s             17a

      /free

           // let the user input the key data
           dsply 'Key data' '' key;

           // let the user input the message data
           dsply 'Message data' '' msg;

           // enqueue *USRQ E006
           msg_len = %len(%trimr(msg));
           enq( q_name
              : subtype
              : key_len
              : key
              : msg_len
              : msg );

           // now check the enqueued entry by command DSPQMSG
           *inlr = *on;
      /end-free
     /* EOF - t168.rpgle */
