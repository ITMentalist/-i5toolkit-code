     /**
      * @file t138.rpgle
      *
      * Test of _MATSOBJ.
      */

     h dftactgrp(*no)

      /copy mih52
     d len             s             10i 0
     d tmpl            ds                  likeds(matsobj_tmpl_t)
     d pgm_obj         s               *
     d start           s               *   inz(%addr(tmpl))
     d pos             s               *

      /free
           len = %size(tmpl);
           dsply 'DS MATSOBJ_TMPL_T' '' len;

           rslvsp_tmpl.obj_type = x'0201';
           rslvsp_tmpl.obj_name = 'T137';
           rslvsp2(pgm_obj : rslvsp_tmpl);

           tmpl.bytes_in = %size(tmpl);
           matsobj(tmpl : pgm_obj);

           pos = %addr(tmpl.domain);
           len = pos - start;
           dsply 'offset of domain' '' len;

           pos = %addr(tmpl.obj_size2);
           len = pos - start;
           dsply 'offset of obj_size2' '' len;

           *inlr = *on;
      /end-free
