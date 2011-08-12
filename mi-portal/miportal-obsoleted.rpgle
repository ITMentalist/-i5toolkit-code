     /**
      * @remark ILE RPG is obviously not a good choice.
      */

      /copy mih-spc
      /copy mih-spt

     d only_u          pr                  extpgm('MIPORTAL')
      * instruction index
     d   inst_inx                     5u 0
      * operand 1
     d   op1                          1a   options(*varsize : *nopass)
     d   op2                          1a   options(*varsize : *nopass)
     d   op3                          1a   options(*varsize : *nopass)
     d   op4                          1a   options(*varsize : *nopass)

     d only_u          pi
     d   inst_inx                     5u 0
     d   op1                          1a   options(*varsize : *nopass)
     d   op2                          1a   options(*varsize : *nopass)
     d   op3                          1a   options(*varsize : *nopass)
     d   op4                          1a   options(*varsize : *nopass)

     d parms           s              5i 0
     d @op1            s               *
     d @op2            s               *
     d @op3            s               *
     d @op4            s               *

     d uuid            ds                  likeds(uuid_t)
     d                                     based(@op1)

      /free
           parms = %parms();
           if parms > 0;
               @op1 = %addr(op1);
               if parms > 1;
                   @op2 = %addr(op2);
                   if parms > 2;
                       @op3 = %addr(op3);
                       if parms > 3;
                           @op4 = %addr(op4);
                       endif;
                   endif;
               endif;
           else;
               *inlr = *on;
               return;
           endif;

           select;
           when inst_inx = 1;
               exsr MATMATR_K;
           when inst_inx = 2;
               exsr GENUUID_K;
           endsl;

           *inlr = *on;

           // index = 1. MATMATR
           begsr MATMATR_K;
               dsply 'ha' '' inst_inx;
           endsr;

           // index = 2. GENUUID
           begsr GENUUID_K;
               genuuid(uuid);
           endsr;

      /end-free
