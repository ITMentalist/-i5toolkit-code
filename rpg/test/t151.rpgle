     /**
      * @file t151.rpgle
      *
      * Test of _MATPG. ODT analysis (scalar data objects).
      */
     h dftactgrp(*no) bnddir('UANDI')

      /copy mih52
      /copy uandi

     d pep             pr                  extpgm('T151')
     d     pgm_name                  10a

     d parse_odt       pr
     d                                 *   value

     d rcv             ds                  likeds(matpg_tmpl_t)
     d                                     based(bufptr)
     d bufptr          s               *
     d len             s             10i 0
      * OPM MI program
     d pgm             s               *
     d odv_ptr         s               *
     d oes_ptr         s               *
     d odv_len         s             10u 0 based(odv_ptr)
     d i               s             10i 0

     d pep             pi
     d     pgm_name                  10a

      /free

           rslvsp_tmpl.obj_type = x'0201';
           rslvsp_tmpl.obj_name = pgm_name;
           rslvsp2(pgm : rslvsp_tmpl);

           len = 8;
           bufptr = modasa(len);
           rcv.bytes_in = len;
           matpg(rcv : pgm);

           len = rcv.bytes_out;
           bufptr = modasa(len);
           rcv.bytes_in = len;
           matpg(rcv : pgm);
             // check rcv

           odv_ptr = bufptr + rcv.odv_offset;
           oes_ptr = bufptr + rcv.oes_offset;

           odv_ptr += 4;
           for i = 1 to rcv.num_odv1;
               parse_odt(odv_ptr);
               odv_ptr += 4;
           endfor;

           *inlr = *on;
      /end-free

     p parse_odt       b
     d parse_odt       pi
     d     odv_ptr                     *   value

     d scalar_info_t   ds                  qualified
      *
      * scalar type
      *  - h'0000', signed binary
      *  - h'0001', floating-point
      *  - h'0002', zoned decimal
      *  - h'0003', packed decimal
      *  - h'0004', character string
      *  - h'0100', unsigned binary
      *
     d     type                       5u 0
      * addressiblity attribute
     d     addr                       5u 0
     d     bdry                       5u 0
     d     opt                        1a
      * use system initial value or not?
      *  - '1', use
      *  - '0', NOT use
     d     sys_init_val...
     d                                1a
      * name length (1-32)
     d     name_len                   5u 0
      * offset from the start of the OES component
     d     name_off                  10u 0
      * scalar length
     d     length                    10u 0
      * fractional part of scalar length
     d     length_hi                  5u 0 overlay(length)
      * total digits of scalar length
     d     length_lo                  5u 0 overlay(length:3)
      * number of array elements
     d     arr_elem                  10u 0
      * array element offset (AEO)
     d     aeo                        5u 0
      * lower bound of array
     d     arr_lb                    10i 0
      * upper bound of array
     d     arr_ub                    10i 0
      * based on ODT reference
     d     base_odt                   5u 0
      * position value, start from 1
     d     pos_val                   10u 0
      * init-val appendage
      *
      * use replication format or not ('1', '0')
      *
     d     rep_fmt_flag...
     d                                1a
      * offset to init-value "OR" rep-fmt-data
     d     init_val_off...
     d                               10u 0
      * length of init-value "OR" rep-fmt-data
     d     init_val_len...
     d                               10u 0

     d odve            ds                  based(odv_ptr)
     d                                     likeds(odv_entry_t)
     d sc_info         ds                  likeds(scalar_info_t)
     d f2              s              5u 0
     d b2              s              5u 0
     d f4              s             10u 0
     d grp_1           s               n   inz(*on)
     d has_oes         s               n   inz(*off)
     d has_oes_ext     s               n   inz(*off)
     d oes_start       s               *
     d oes_hdr         s              1a   based(oes_start)
     d oes_ext         s              1a
      * current offset into the OES (start from OES_START)
     d cur_oes_off     s             10u 0

      /free
           f2 = cvt_bits2(odve.hi:2:0:4);
           b2 = cvt_bits2(odve.hi:2:13:3);
           if f2 = 0;       // group-1
               sc_info.type = b2;
           elseif f2 = 9;  // group-2
               sc_info.type = b2;
               setbts(%addr(sc_info.type) : 7);
           else;  // not a scalar
               return;
           endif;

           // has corresponding OES entries
           if tstbts(%addr(odve.hi):4) > 0;
               has_oes = *on;
               oes_start = oes_ptr + odve.oes_offset;
               if tstbts(%addr(oes_hdr) : 7) > 0;
                   has_oes_ext = *on;
                   memcpy(%addr(oes_ext) : oes_start + 1 : 1);
               endif;
           endif;

           // addr attr
           sc_info.addr = cvt_bits2(odve.hi:2:5:3); // bits 5-7

           // boundary attr
           sc_info.bdry = cvt_bits2(odve.hi:2:9:3); // bits 9-11

           // ABN
           sc_info.opt  = '0';
           if tstbts(%addr(odve.hi):8) > 0;
               sc_info.opt = '1';
           endif;

           // use system initial value or not?
           sc_info.sys_init_val = '0';
           if tstbts(%addr(odve.hi):12) > 0;
               sc_info.sys_init_val = '1';
           endif;

           // name attr
           if tstbts(%addr(oes_hdr) : 0) > 0;
           endif;

      /end-free
     p parse_odt       e
