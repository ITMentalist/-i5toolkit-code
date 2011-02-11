     /**
      * @file t155.rpgle
      *
      * Test of _MATPG. Materialize the OMT component of an OPM MI program.
      */
     h dftactgrp(*no)

      /copy mih52
     d pep             pr                  extpgm('T155')
     d     pgm_name                  10a

     d rcv             ds                  likeds(matpg_tmpl_t)
     d                                     based(bptr)
     d bptr            s               *
     d len             s             10u 0
     d pgm             s               *
     d omt_ptr         s               *
     d omte            ds                  likeds(omt_entry_t)
     d                                     based(omt_ptr)
     d i               s             10i 0
     d

     d pep             pi
     d     pgm_name                  10a

      /free
           // resolve target OPM PGM
           rslvsp_tmpl.obj_type = x'0201';
           rslvsp_tmpl.obj_name = pgm_name;
           rslvsp2(pgm : rslvsp_tmpl);

           // ...
           len = 8;
           bptr = modasa(len);
           rcv.bytes_in = len;
           matpg(rcv : pgm);

           len = rcv.bytes_out;
           bptr = modasa(len);
           rcv.bytes_in = len;
           matpg(rcv : pgm);

           // is the OMT component materializable?
           if tstbts(%addr(rcv.obsv_attr) : 5) = 0;
               *inlr = *on;
               return;
           endif;

           omt_ptr = bptr + rcv.omt_offset;
           for i = 1 to rcv.num_odv1;
               // check omt entry: addr-type, offset-from-base, ...

               omt_ptr += %size(omt_entry_t);
           endfor;

           *inlr = *on;
      /end-free
