     h dftactgrp(*no)
     fQSYSPRT   O    f  132        printer

      /copy mih-prcthd.rpgleinc
     d w               s              1a
     d item_name       s             40a   inz('Item name')
     d item_value      s            120a   inz('...')
     d psts            ds                  likeds(matpratr_20_t)
     d opt             s              1a   inz(x'20')
     d a2              s              2a

      /free
           // Materialize process state indicators of the current MI process
           psts.bytes_in = %len(matpratr_20_t);
           matpratr1(psts : opt);

           // Current process phase -- bits 8-10 of thd_state
           a2 = %bitand(psts.thd_state : x'00E0');
           item_name = 'Current process phase:';
           except ITEMREC;
           select;
           when a2 = x'0020';
               item_value = 'Initiation phase';
           when a2 = x'0040';
               item_value = 'Problem phase';
           when a2 = x'0080';
               item_value = 'Termination phase';
           endsl;
           except VALREC;

           // Invocation exit active?
           item_name = 'Invocation exit active:';
           except ITEMREC;
           a2 = %bitand(psts.thd_state : x'1000');
           if a2 = x'0000';
               item_value = 'No';
           else;
               item_value = 'Yes';
           endif;
           except VALREC;

           if a2 = x'0000';
           //  *inlr = *on;
           //  return;
           endif;

           // Initial internal termination reason
           item_name = 'Initial internal termination reason:';
           except ITEMREC;
           select;
           when psts.iit_reason = x'80';
               item_value = 'Return from first invocation '
                   + 'in problem phase';
           when psts.iit_reason = x'40';
               item_value = 'Return from first invocation in '
                   + 'initiation phase and no problem phase program '
                   + 'specified';
           when psts.iit_reason = x'21';
               item_value = 'Terminate Thread instruction issued against '
                   + 'the initial thread by a thread in the process';
           when psts.iit_reason = x'20';
               item_value = 'Terminate Process instruction issued '
                   + 'by a thread within the process';
           when psts.iit_reason = x'18';
               item_value = 'An unhandled signal with a default signal '
                   + 'handling action of terminate the process or '
                   + 'terminate the request was delivered to the process';
           when psts.iit_reason = x'10';
               item_value = 'Exception was not handled by the initial '
                   + 'thread in the process';
           when psts.iit_reason = x'00';
               item_value = 'Process terminated externally';
           endsl;
           except VALREC;

           // Initial external termination reason
           item_name = 'Initial external termination reason:';
           except ITEMREC;
           select;
           when psts.iet_reason = x'80';
               item_value = 'Terminate Process instruction issued '
                   + 'explicitly to the process by a thread in '
                   + 'another process';
           when psts.iet_reason = x'40';
               item_value = 'Terminate Thread instruction issued '
                   + 'explicitly to the initial thread of the process '
                   + 'by a thread in another process';
           when psts.iet_reason = x'00';
               item_value = 'Process terminated internally';
           endsl;
           except VALREC;

           *inlr = *on;
      /end-free

     oQSYSPRT   e            ITEMREC
     o                       item_name

     oQSYSPRT   e            VALREC
     o                       w                    5
     o                       item_value
