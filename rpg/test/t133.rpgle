     /**
      * @file t133.rpgle
      *
      * Retrieving UPS information by materializing the MISR.
      *
      * UPS installed? Bit 8 of matmatr_misr_t.misr_status.
      * Running on UPS? Bit 7 of matmatr_misr_t.misr_status.
      * UPS battery low? Bit 5 of matmatr_misr_t.misr_status.
      *
      * Bit 39 of matmatr_misr_t.misr_status:
      *   Termination due to utility power failure and user specified
      *   delay time exceeded?
      * Bit 40 of matmatr_misr_t.misr_status:
      *   Termination due to utility power failure and battery low?
      *
      */
     h dftactgrp(*no)

      /copy mih52
     d tmpl            ds                  likeds(matmatr_tmpl_t)
     d                                     based(ptr)
     d ptr             s               *
     d misr            ds                  likeds(matmatr_misr_t)
     d                                     based(misr_ptr)
     d misr_ptr        s               *
     d len             s             10i 0
     d opt             s              2a
     d msg             s             10a
     d has_ups         s               n   inz(*on)

      /free
           len = %size(misr); // len = 592

           ptr = modasa(8);
           tmpl.bytes_in = 8;
           opt = x'0108';    // materialize MISR info
           matmatr(tmpl : opt);

           len = tmpl.bytes_out;
           ptr = modasa(len);
           tmpl.bytes_in = len;
           matmatr(tmpl : opt);

           misr_ptr = ptr + 8;
           if tstbts(%addr(misr.misr_status) : 8) = 1;
               msg = 'Yes';
           else;
               msg = 'No';
               has_ups = *off;
           endif;
           dsply 'Is UPS installed?'
             '' msg;

           if not has_ups;
               *inlr = *on;
               return;
           endif;

           if tstbts(%addr(misr.misr_status) : 7) = 1;
               msg = 'Yes';
           else;
               msg = 'No';
           endif;
           dsply 'Currently running on UPS?'
             '' msg;

           if tstbts(%addr(misr.misr_status) : 5) = 1;
               msg = 'Yes';
           else;
               msg = 'No';
           endif;
           dsply 'Is UPS battery low?'
             '' msg;

           *inlr = *on;
      /end-free
