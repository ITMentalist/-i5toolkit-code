     /**
      * @file t148.rpgle
      *
      * Test of _MATPG. ODT analysis.
      */
     h dftactgrp(*no)

      /copy mih52

     d pep             pr                  extpgm('T148')
     d     pgm_name                  10a

     d rcv             ds                  likeds(matpg_tmpl_t)
     d                                     based(bufptr)
     d bufptr          s               *
     d len             s             10i 0
      * OPM MI program
     d pgm             s               *
     d odv_ptr         s               *
     d oes_ptr         s               *

     d pep             pi
     d     pgm_name                  10a

      /free
           len = %size(rcv);
           dsply 'length of matpg_tmpl_t' '' len;

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

           *inlr = *on;
      /end-free

     /**
      * 5722SS1 V5R4M0 060210                                Generated Output                                 10/11/15 17:43:55  Page     1
      *  SEQ   INST Offset    Generated Code     *... ... 1 ... ... 2 ... ... 3 ... ... 4 ... ... 5 ... ... 6 ... ... 7 ... ... 8   Break
      * 00001                                             DCL DD A PKD(7,5) AUTO INIT(P'15.67')                                 ;
      * 00002                                             DCL DD POSITIVE-FLAG CHAR(1) AUTO INIT('0')                           ;
      * 00003                                             DCL DD ONE-FLAG CHAR(1) AUTO INIT('0')                                ;
      * 00004  0001 000004  3846 1000 0001 2000           CMPNV(I) A, 0 / HI(POSITIVE-FLAG)                                     ;
      *                     0002
      * 00005  0002 00000E  1846 4000 0001 2001           CMPNV(I) A, 1 / EQ(ONE-FLAG)                                          ;
      *                     0003
      * 00006                                             BRK "SEE-YOU"                                                         ;  SEE-YOU
      * 00007  0003 000018  02A1 0000                     RTX *                                                                 ;  SEE-YOU
      * 00008  0004 00001C  0260                          PEND                                                                  ;  SEE-YOU
      * 5722SS1 V5R4M0 060210                                Generated Output                                 10/11/15 17:43:55  Page     2
      *  ODT  ODT Name                                         Attributes and ODV/OES Entries
      *  0001 A                                                DATA OBJECT,AUTOMATIC,PACKED(7,5),INTERNAL,INITIAL VALUE.
      *                                                        09030004/4405071567000F
      *  0002 POSITIVE-FLAG                                    DATA OBJECT,AUTOMATIC,CHARACTER(1),INTERNAL,INITIAL VALUE.
      *                                                        0904000B/440001F0
      *  0003 ONE-FLAG                                         DATA OBJECT,AUTOMATIC,CHARACTER(1),INTERNAL,INITIAL VALUE.
      *                                                        0904000F/440001F0
      * 5722SS1 V5R4M0 060210                                Generated Output                                 10/11/15 17:43:55  Page     3
      *  MSGID    ODT   ODT Name                                          Semantics and ODT Syntax Diagnostics
      * 5722SS1 V5R4M0 060210                                Generated Output                                 10/11/15 17:43:55  Page     4
      * ODT  ODT Name                         SEQ Cross Reference       (* Indicates Where Defined)
      * 0001 A                                                1* 4 5
      * 0003 ONE-FLAG                                         3* 5
      * 0002 POSITIVE-FLAG                                    2* 4
      */
