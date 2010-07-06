     /**
      * @file t079.rpgle
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
     d opt             s              1a
     d                 ds
     d      priority                  5u 0
     d      low_pri                   1a   overlay(priority:2)

      /free
           opt = x'0E';
           tmpl.bytes_in = %size(process_priority_t);

           matpratr1(tmpl : opt);
           priority = 0;
           low_pri = tmpl.priority;
           priority -= 156;

           dsply 'Process priority' '' priority;
           *inlr = *on;
      /end-free
