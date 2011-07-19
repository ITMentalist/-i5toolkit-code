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
      * @file t169.rpgle
      *
      * Test of _MATMATR
      *  - materializing cryptography attributes, option hex 01C8
      */

     h dftactgrp(*no)
     fQSYSPRT   o    f  132        disk

      /copy mih-spt
      /copy mih-comp

     d tmpl            ds                  likeds(crypto_attr_t)
     d option          s              2a   inz(x'01C8')
     d i               s              5i 0
     d                 ds
     d alg_name                     240a   inz('MAC             -
     d                                     MD5             -
     d                                     SHA-1           -
     d                                     DES (Enc only)  -
     d                                     DES             -
     d                                     RC4             -
     d                                     RC5             -
     d                                     DESX            -
     d                                     Trypile-DES     -
     d                                     DSA             -
     d                                     RSA             -
     d                                     Diffie-Hellman  -
     d                                     CDMF            -
     d                                     RC2             -
     d                                     AES             ')
     d alg                           16a   dim(15)
     d                                     overlay(alg_name)

     d ws              s              2a
     d num             s              2s 0
     d algorithm       s             16a
     d max_key_len     s              4s 0
     d provider        s             20a

      /free
           tmpl.bytes_in = %size(tmpl);
           matmatr(tmpl : option);

           for i = 1 to tmpl.num_alg_entries;
               num = i;
               algorithm = alg(tmpl.entries(i).alg_id);
               max_key_len = tmpl.entries(i).max_key_length;

               provider = 'Unknown';
               if tstbts(%addr(tmpl.entries(i).provider) : 0) > 0;
                   provider = 'Machine';
               elseif tstbts(%addr(tmpl.entries(i).provider) : 1) > 0;
                   provider = 'BSAFE';
               elseif tstbts(%addr(tmpl.entries(i).provider) : 3) > 0;
                   provider = '4758 Cryptographic Adapter';
               endif;

               except ALGREC;
           endfor;

           *inlr = *on;
      /end-free

     oQSYSPRT   e            ALGREC
     o                       num
     o                       ws
     o                       algorithm
     o                       max_key_len
     o                       ws
     o                       provider

     /**
      * output of t169 might like the following
      *   01  MAC             1024  Machine    
      *   02  MD5             0000  Machine    
      *   03  SHA-1           0000  Machine    
      *   04  DES (Enc only)  0056  Machine    
      *   ... ...
      */
