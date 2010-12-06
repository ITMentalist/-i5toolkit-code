     /**
      * @file t145.rpgle
      *
      * Test of _MATPG. Materialize BOM info.
      *
      * @param[in] pgm-name, CHAR(10)
      */
     h dftactgrp(*no)

     fQSYSPRT   o    f  132        disk

      /copy mih52

     d i_t145          pr                  extpgm('T145')
     d    pgm_name                   10a

     d yes_or_no       pr            10a
     d    flag                        1a
     d    off                         5i 0 value
     d    zero_is_y                   5i 0 value

     d rcv             ds                  likeds(matpg_tmpl_t)
     d                                     based(bufptr)
     d bufptr          s               *
     d len             s             10i 0
     d pgmptr          s               *
     d msg             s             32a
     d an              s             10a
     d yes             c                   '*AVAIL'
     d no              c                   '*UNAVAIL'

     d i_t145          pi
     d     pgm_name                  10a

      /free
           rslvsp_tmpl.obj_type = x'0201';
           rslvsp_tmpl.obj_name = pgm_name;
           rslvsp2(pgmptr : rslvsp_tmpl);

           len = 8;
           bufptr = modasa(len);
           rcv.bytes_in = len;
           matpg(rcv : pgmptr);

           len = rcv.bytes_out;
           bufptr = modasa(len);
           rcv.bytes_in = len;
           matpg(rcv : pgmptr);

           // program name
           msg = 'Program name';
           an = pgm_name;
           except OBVREC;

           // has template extension?
           msg = 'Template extension exists';
           an = yes_or_no(rcv.pgm_attr:10:0);

           // BOM format
           msg = 'BOM table format';
           an = 'OLD';
           if tstbts(%addr(rcv.bom_flags):0) > 0;
               an = 'NEW';
           endif;
           except OBVREC;

           // observation attributes (obsv_attr)
           msg = 'Instruction stream';
           an = yes_or_no(rcv.obsv_attr:0:0);
           except OBVREC;

           msg = 'ODV';
           an = yes_or_no(rcv.obsv_attr:1:0);
           except OBVREC;

           msg = 'OES';
           an = yes_or_no(rcv.obsv_attr:2:0);
           except OBVREC;

           msg = 'BOM table';
           an = yes_or_no(rcv.obsv_attr:3:0);
           except OBVREC;

           msg = 'Symbol table';
           an = yes_or_no(rcv.obsv_attr:4:0);
           except OBVREC;

           msg = 'OMT table';
           an = yes_or_no(rcv.obsv_attr:6:0);
           except OBVREC;

           *inlr = *on;
      /end-free

     oQSYSPRT   e   nLR      OBVREC
     o                       msg
     o                       an

     p yes_or_no       b
     d yes_or_no       pi            10a
     d    flag                        1a
     d    off                         5i 0 value
     d    zero_is_y                   5i 0 value

     d bit_on          s               n

      /free
           bit_on = *off;
           if tstbts(%addr(flag) : off) > 0;
               bit_on = *on;
           endif;

           if zero_is_y = 1;
               bit_on = not bit_on;
           endif;

           if bit_on;
               return yes;
           else;
               return no;
           endif;

      /end-free
     p yes_or_no       e

