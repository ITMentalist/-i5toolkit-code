     /**
      * @file crtmdr01.rpgle
      *
      * @pre 1934 space CRTMD
      * x quscrtus ('CRTMD     QTEMP' 'CRTMD' x'00200000' x'00' '*ALL' '')
      */

     h dftactgrp(*no)

     fCRTMD     if   f  528        disk
      /copy mih-ptr
     d rec             ds
     d   rcd                        512a
     d                               16a
     d                 ds
     d oddptr                          *   procptr
     d spc16                           *   overlay(oddptr)
     d spp             s               *
     d ch512           s            512a   based(spp)
     d off             s             10u 0 inz(0)

      /free
           rslvsp_tmpl.obj_type = x'1934';
           rslvsp_tmpl.obj_name = 'CRTMD';
           rslvsp2(spc16 : rslvsp_tmpl);
           spp = setsppfp(oddptr);

           read CRTMD rec;
           dow not %eof(CRTMD);
               off += x'0200';

               if off > x'5000'; // Content of QWXCRTMD
                   ch512 = rcd;
                   spp += 512;
               endif;

               read CRTMD rec;
           enddo;
           *inlr = *on;
      /end-free
