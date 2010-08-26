     /**
      * @file t125.rpgle
      *
      * Test of ENSOBJ.
      *
      * CL command to create *USRSPC T125:
      * CALL PGM(QUSCRTUS) PARM('T125      *CURLIB' 'ROBUST' X'00001000'
      *        X'00' '*CHANGE' 'i''m robust :)')
      */
     h dftactgrp(*no)

      /copy mih52
     d                 ds
     d spc                             *
     d funny_ptr                       *   procptr
     d                                     overlay(spc)
     d greeting        s             16a   based(spcptr)
     d spcptr          s               *

      /free
           rslvsp_tmpl.obj_type = x'1934';
           rslvsp_tmpl.obj_name = 'T125';
           rslvsp2(spc : rslvsp_tmpl);

           // retrieve space pointer addressing T125
           spcptr = setsppfp(funny_ptr);

           // write T125 and and ensure data to persistent storage media
           greeting = 'To be robust :)';
           ensobj(spc);

           *inlr = *on;
      /end-free
