     /**
      * @file t131.rpgle
      *
      * Test of SETACST.
      */

     h dftactgrp(*no)

      /copy mih52
     d tmpl            ds                  likeds(access_state_tmpl_t)
     d                                     based(ptr)
     d ptr             s               *

      /free
           ptr = %alloc(80);
           propb(ptr : x'00' : 80);
           tmpl.num_objs = 1;

           rslvsp_tmpl.obj_type = x'0201';
           rslvsp_tmpl.obj_name = 'T130';
           rslvsp2(tmpl.spec(1).obj : rslvsp_tmpl);
           tmpl.spec(1).state_code = x'10';
           setacst(tmpl);

           dsply 'operational object size' ''
             tmpl.spec(1).operational_object_size;

           dealloc ptr;

           *inlr = *on;
      /end-free
