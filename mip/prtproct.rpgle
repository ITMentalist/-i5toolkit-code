     /**
      * @file prtproct.rpgle
      *
      * Print the following fields of each QPROCT entry:
      *  - BIN(2) op-code
      *  - CHAR(8) instruction name
      *  - BIN(2) number of required operands
      *
      * @remark It's recommended that you create a copy of the QPROCT
      *         and pass it's name to this program.
      */

     h dftactgrp(*no) bnddir('QC2LE')
     fQSYSPRT   o    f  132        disk

      /copy mih-ptr
     d i_main          pr                  extpgm('PRTPROCT')
     d   obj_name                    10a
     d   obj_type                     2a

     d rt              ds                  likeds(rslvsp_tmpl)
     d                 ds
     d proct                           *
     d proct_rpg                       *   procptr
     d                                     overlay(proct)
     d pos             s               *
     d proce           ds            17    based(pos)
     d   instnam                      8a
     d   opcode                       2a
     d   flag3                        3a
     d   reqopnds                     5u 0
     d                                2a
     d dword           s              4a   based(pos)
     d operands        s              1s 0
     d stropcode       s              7a
     d wss             s              3a
     d cvthc           pr                  extproc('cvthc')
     d                                1a   options(*varsize)
     d                                1a   options(*varsize)
     d                               10i 0 value

     d i_main          pi
     d   obj_name                    10a
     d   obj_type                     2a

      /free
           rt = *allx'00';
           rt.obj_type = obj_type;
           rt.obj_name = obj_name;
           rslvsp2( proct : rt );

           pos = setsppfp( proct_rpg );
           pos += 1126; // hex 0466

           dow dword <> x'00000000';
               cvthc( stropcode : opcode : 4);
               operands = reqopnds;

               except REC;
               pos += 17;
           enddo;

           *inlr = *on;
      /end-free

     oQSYSPRT   e            REC
     o                       stropcode
     o                       wss
     o                       instnam
     o                       wss
     o                       operands
