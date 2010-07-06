     /**
      * @file t080.rpgle
      *
      * Retrieve run priority of the current MI process.
      *
      * Call this program directly or first change the RUNPTY attribute of
      * the current MI project like the following:
      * @code
      * CHGJOB RUNPTY(55)
      * @endcode
      */
     h dftactgrp(*no)

      /copy mih52
     d tmpl            ds                  likeds(
     d                                       process_priority_t)
     d ptr_tmpl        ds                  likeds(
     d                                       matpratr_ptr_tmpl_t)
     d opt             s              1a
     d                 ds
     d      priority                  5u 0
     d      low_pri                   1a   overlay(priority:2)

      /free
           opt = x'25'; // materialize PCS ptr
           ptr_tmpl.bytes_in = %size(matpratr_ptr_tmpl_t);
           matpratr1(ptr_tmpl : opt);

           opt = x'0E'; // materialize process priority
           tmpl.bytes_in = %size(process_priority_t);
           matpratr2( tmpl
                    : ptr_tmpl.ptr
                    : opt );
           priority = 0;
           low_pri = tmpl.priority;
           priority -= 156;

           dsply 'Process priority' '' priority;
           *inlr = *on;
      /end-free
