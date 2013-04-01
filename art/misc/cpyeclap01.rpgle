     /**
      * @file cpyeclap01.rpgle
      */

     h dftactgrp(*no)

      /copy mih-comp
      /copy mih-dtaptr

      * OPEN fields
      * long_o contains 4 DBCS characters: 'ＨＩＧＨ'
     d long_o          s             10a   inz(x'0E42C842C942C742C80F')
     d short_o         s              6a
     d @long_o         s               *
     d @short_o        s               *
      * EITHER fields
     d long_e          s              8a
     d short_e         s              4a   inz('abcd')
     d @long_e         s               *
     d @short_e        s               *

     d dpat            ds                  likeds(dpat_t)
     d pad             ds                  likeds(cpyeclap_pad_t)

      /free
           // Set up data pointers
           dpat = *allx'00';
           dpat.type = DPAT_OPEN;
           dpat.len  = 10;
           @long_o   = setdp( %addr(long_o) : dpat);
           dpat.len  = 6;
           @short_o  = setdp( %addr(short_o) : dpat);

           // [1] Test for truncation
           cpyeclap( @short_o : @long_o : pad );
             // Result: 

           // Test for padding
           dpat.type = DPAT_EITHER;
           dpat.len  = 10;
           @long_e   = setdp( %addr(long_e) : dpat);
           dpat.len  = 4;
           @short_e  = setdp( %addr(short_e) : dpat);
           pad.single_byte_pad_value = '-';
           // [2.1] SB padding should be performed
           cpyeclap( @long_e : @short_e : pad );
             // Result: 

           // [2.2] DB||SI padding should be performed
           short_e   = x'0E42C50F';     // DBCS character: 'Ｅ'
           pad.double_byte_pad_value = x'42C7';  // Set DB pad character to ' Ｇ'
           cpyeclap( @long_e : @short_e : pad );
             // Result: 

           *inlr = *on;
      /end-free

