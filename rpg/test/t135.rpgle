     /**
      * @file t135.rpgle
      *
      * Test of MATS
      */

     h dftactgrp(*no)

      /copy mih52
     d uept            s               *
     d tmpl            ds                  likeds(mats_tmpl_t)
     d mod_tmpl        ds                  likeds(mods_tmpl_t)
     d auto_extend     s               n   inz(*off)

      /free

           rslvsp_tmpl.obj_type = x'1934';
           rslvsp_tmpl.obj_name = 'UEPT';
           rslvsp2(uept : rslvsp_tmpl);

           tmpl.bytes_in = %size(tmpl);
           mats(tmpl : uept);

           // check creation options of target space object

           // Automatically extend space
           if tstbts(%addr(tmpl.crt_option) : 14) > 0;
               auto_extend = *on;
           else;
               mod_tmpl = *allx'00';
               // Modify automatically extend space attribute
               setbts(%addr(mod_tmpl.selection) : 6);
               // Automatically extend space = Yes
               setbts(%addr(mod_tmpl.attr) : 3);
               mods2(uept : mod_tmpl);
           endif;

           *inlr = *on;
      /end-free
