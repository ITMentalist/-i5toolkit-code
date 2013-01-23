     /**
      * @file spc02.rpgle
      *
      * Exemple program used in the SPCTRK article
      */
     h dftactgrp(*no)
     fQSYSPRT   o    f  132        printer
      * SYSBIF memchr()
      /copy mih-comp

     d qual_name_t     ds                  qualified
     d   obj                         10a
     d   lib                         10a

      * My prototype
     d i_main          pr                  extpgm('SPC02')
     d   spc_name                          likeds(qual_name_t)

      * Materialize space size
     d matspsz         pr            10i 0

      * Prototype of the Retrieve Pointer to User Space API
     d qusptrus        pr                  extpgm('QUSPTRUS')
     d   spc_name                          likeds(qual_name_t)
     d   @spp                          *

     d @spp            s               *
     d c               s          32767a   based(@spp)
     d spsz            s             10i 0
     d disp            s             10i 0
     d ln              s            132a
      * Newline character
     d NL              c                   x'25'
     d @pos            s               *

     d i_main          pi
     d   spc_name                          likeds(qual_name_t)

      /free
           // Retrieve a space pointer addressing the USRSPC's
           // associated space
           qusptrus(spc_name : @spp);
           spsz = matspsz();           // Retrieve USRSPC size
           @pos = memchr(@spp : NL : spsz);   // Search for NL
           dow @pos <> *null;
               disp = @pos - @spp;
               spsz -= disp + 1;

               if disp < 132;
                   ln = %subst(c:1:disp);
               else;
                   ln = c;
               endif;
               except OREC;

               // Offset @spp and search for next NL character
               @spp = @pos + 1;
               @pos = memchr(@spp : NL : spsz);               
           enddo;

           *inlr = *on;
      /end-free

     oQSYSPRT   e            OREC
     o                       ln

     p matspsz         b
      * Space attribute in format SPCA0100 returned by QUSRUSAT
     d spca0100_t      ds                  qualified
     d   bytes_returned...
     d                               10i 0
     d   bytes_available...
     d                               10i 0
     d   spc_size                    10i 0
     d   auto_extend                  1a
     d   init_value                   1a
     d   lib_name                    10a
      * Prototype of the Retrieve User Space Attributes API
     d qusrusat        pr                  extpgm('QUSRUSAT')
     d   attr                              likeds(spca0100_t)
     d   rcv_len                     10i 0
     d   fmt_name                     8a
     d   spc_name                          likeds(qual_name_t)
     d   ec                           8a   options(*varsize)

     d attr            ds                  likeds(spca0100_t)
     d rcv_len         s             10i 0 inz(%size(attr))
     d fmt_name        s              8a   inz('SPCA0100')
     d ec              s              8a   inz(*allx'00')
     d matspsz         pi            10i 0
      /free
           qusrusat(attr : rcv_len : fmt_name : spc_name : ec);
           return attr.spc_size;
      /end-free
     p                 e
