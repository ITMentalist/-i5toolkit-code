     /**
      * @file t070.rpgle
      *
      * test of CHKLKVAL/CLRLKVAL
      */
     h dftactgrp(*no)

      /copy mih54

      * user code
     d lock            s             20i 0 inz(0)
     d rtn             s             10i 0
     d tmpl            ds                  likeds(wait_tmpl_t)

      /free

           propb (%addr(tmpl) : x'00' : 16);
           tmpl.interval = sysclock_one_second;
           tmpl.option   = x'1000';

           dow chklkval(lock : 0 : 1) = 1;
               waittime(tmpl);
           enddo;

           dsply 'Yeah! I got it!' '' lock;

           clrlkval(lock : 0);

           *inlr = *on;
      /end-free

