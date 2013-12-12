     /**
      * @file rexq01.rpgle
      *
      * Query the number of lines in the Rexx queue.
      */

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
      */
     d rexq01          pr                  extpgm('REXQ01')
     d                               11p 0

     d func            s              1a   inz('Q')
     d num             s             10u 0
     d op_flg          s              5u 0
     d rc              s              5u 0

     d rexq01          pi
     d   queued                      11p 0

      /free
           qrexq( func
                : *inlr
                : num
                : op_flg
                : rc );

           queued = num;
           *inlr = *on;
      /end-free
