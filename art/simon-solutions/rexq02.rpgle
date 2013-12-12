     /**
      * @file rexq01.rpgle
      *
      * PUSH one line from the QREXXDATAQ.
      */
     h dftactgrp(*no)

     /**
      * RPG prototype of the QREXQ API.
      */
     d qrexq           pr                  extpgm('QREXQ')
      * Requested function code
     d   func                         1a
      * Data buffer
     d   buf                          1a   options(*varsize)
      * Length / Number
     d   len_num                     10u 0
      * Operation flag
     d   op_flg                       5u 0
      * Return code
     d   rc                           5u 0

     /**
      * Prototype of this program
      *
      * Parameters:
      * - msg. Data of the line pulled from the REXX data queue (INTPUT).
      * - buflen. Length of the data buffer (INPUT).
      * - msglen. On return, it is set to the length of the pulled line
      *   data, or -1 if the REXX data queue is empty (OUTPUT).
      */
     d rexq02          pr                  extpgm('REXQ02')
     d   msg                          1a   options(*varsize)
     d   buflen                      11p 0
     d   msglen                      11p 0

      * System built-in _memcpy
     d memcpy          pr              *   extproc('__memcpy')
     d     target                      *   value
     d     source                      *   value
     d     length                    10u 0 value

     d func            s              1a   inz('P')
     d msg2            s              1a   based(msg@)
     d len             s             10u 0
     d op_flg          s              5u 0
     d rc              s              5u 0

     d rexq02          pi
     d   msg                          1a   options(*varsize)
     d   buflen                      11p 0
     d   msglen                      11p 0

      /free
           len = buflen;
           qrexq( func
                : msg
                : len
                : op_flg
                : rc );
           if rc = 5; // Data buffer too small
               msg@ = %alloc(len);
               qrexq(func : msg2 : len : op_flg : rc);
               memcpy(%addr(msg) : msg@ : buflen);
               dealloc msg@;
           endif;
           msglen = len;

           if rc = 2;
               msglen = -1;
           endif;

           *inlr = *on;
      /end-free
