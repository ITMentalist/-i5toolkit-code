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
      * @file t075.rpgle
      *
      * Display a simple menu panel, t075.pnlgrp.
      */

      /copy uim

     d apph            s              8a
     d pnlgrp          s             20a   inz('T075      *LIBL')
     d scope           s             10i 0 inz(-1)
     d exitpgm_int     s             10i 0 inz(0)
     d full_screen_help...
     d                 s              1a   inz('Y')
     d ec              ds                  likeds(qusec_t)
     d                                     based(ecptr)
     d ecptr           s               *
     d eclen           c                   64
     d rtn             s             10i 0
     d panel           s             10a   inz('MAINPANEL')
     d redisp_opt      s              1a   inz('N')
     d close_opt       s              1a   inz('M')
     d rcd_name        s             10a   inz('RCDTTL')
     d rcd_title       ds            50    qualified
     d     panel_title...
     d                               50a
     d buflen          s             10i 0

      /free
           ecptr = %alloc(eclen);
           ec.bytes_in = eclen;

           // open display application
           quiopnda( apph : pnlgrp : scope : exitpgm_int
                   : full_screen_help : ec);

           if ec.bytes_out <> 0;
               // error handling
           endif;

           // set panel title
           rcd_title.panel_title = 'Hello UIM :p';
           buflen = %size(rcd_title);
           quiputv( apph : rcd_title : buflen : rcd_name : ec);

           // display main panel
           quidspp( apph : rtn : panel : redisp_opt : ec);

           quicloa( apph : close_opt : ec);

           dealloc ecptr;
           *inlr = *on;
      /end-free
