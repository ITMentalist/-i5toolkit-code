     /**
      * @file t132.rpgle
      *
      * Test of libiconv APIs.
      */
     h dftactgrp(*no)

      /copy iconv
     d cd              ds                  likeds(iconv_t)
     d tocode          ds                  likeds(qtqcode_t)
     d fromcode        ds                  likeds(qtqcode_t)
     d rtn             s             10i 0
     d ustr            s              8a   inz(x'6161626263636464')
     d inbufptr        s               *   inz(%addr(ustr))
     d inlen           s             10u 0 inz(8)
     d str             s              8a
     d outbufptr       s               *   inz(%addr(str))
     d outlen          s             10u 0 inz(8)

      /free
           tocode = *allx'00';
           tocode.ccsid = 935;
           fromcode = *allx'00';
           fromcode.ccsid = 1208;
           cd = QtqIconvOpen(tocode : fromcode);
             // check cd.rtn

           rtn = iconv( cd
                      : inbufptr
                      : inlen
                      : outbufptr
                      : outlen );

           rtn = iconv_close(cd);
           *inlr = *on;
      /end-free
