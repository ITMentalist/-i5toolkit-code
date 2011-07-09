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
      * Test of the following queue object APIs
      *  - ENQ
      */

      /copy q-api
      /copy apiec

     d q_name          s             20a   inz('E006      *LIBL')
      * *LIBL/E006 is a pre-created *USRQ
     d subtype         s              1a   inz(x'02')
     d key_len         s             10i 0 inz(9)
     d key             s              9a
     d msg_len         s             10i 0 inz(17)
     d msg             s             17a
     d ec              ds                  likeds(qusec_t)
     d                                     based(ec_ptr)
     d ec_ptr          s               *

     d msg_ptr         s               *
     d msgd3401        ds                  qualified
     d                                     based(msg_ptr)
     d     obj_type                   2a
     d     obj_name                  30a

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

           // call ENQ with the API error code parameter
           q_name = 'NOSUCHONE *LIBL';
           ec_ptr = %alloc(128);
           ec.bytes_in = 128;
           enq( q_name
              : subtype
              : key_len
              : key
              : msg_len
              : msg
              : ec );
           if ec.bytes_out = 0;
               dsply 'Ooops' '' q_name;
           else;
               msg_ptr = ec_ptr + 16;
               if ec.exid = 'MCH3401';
                   dsply 'NO SUCH A Q' '' msgd3401.obj_name;
               endif;
           endif;

           dealloc ec_ptr;

           *inlr = *on;
      /end-free
     /* EOF - t168.rpgle */
