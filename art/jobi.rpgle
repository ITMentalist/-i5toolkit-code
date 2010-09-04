     /**
      * @file jobi.rpgle
      *
      * Retrieve job ID of the current job via QUSRJOBI.  Time used on
      * a 525 mahcine: 784000 microseconds.
      */

      /copy apiec
     d jobi0100_t      ds                  qualified
     d     bytes_in                  10i 0
     d     bytes_out                 10i 0
     d     id                        26a
     d     int_id                    16a
     d     status                    10a
     d     type                       1a
     d     subtype                    1a
     d                                2a
     d     priority                  10i 0
     d     time_slice                10i 0
     d     dft_wait                  10i 0
     d     purge                     10i 0

     d qusrjobi        pr                  extpgm('QUSRJOBI')
     d     rcv                             likeds(jobi0100_t)
     d     len                       10i 0
     d     fmt                        8a
     d     job                       26a
     d     intjid                    16a
     d     ec                              likeds(qusec_t)

     d jobi            ds                  likeds(jobi0100_t)
     d len             s             10i 0 inz(%size(jobi))
     d fmt             s              8a   inz('JOBI0100')
     d job_name        s             26a   inz('*')
     d intjid          s             16a
     d ec              ds                  likeds(qusec_t)
     d i               s             10i 0
     d start           s               z
     d end             s               z
     d dur             s             20i 0
     d COUNT           c                   100000

      /free
           jobi.bytes_in = %size(jobi);
           ec.bytes_in = %size(ec);

           start = %timestamp();
           for i = 1 to COUNT;
               qusrjobi( jobi
                       : len
                       : fmt
                       : job_name
                       : intjid
                       : ec );
           endfor;
           end = %timestamp();

           dur = %diff(end : start : *ms);
           dsply 'microseconds' '' dur;

           *inlr = *on;
      /end-free
