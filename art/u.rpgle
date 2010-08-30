     /**
      * @file u.rpgle
      *
      * Test of the Control Thread (QTHMCTLT) API.
      */

      /copy apiec

     /* CTLT0100 Format */
     d ctlt0100_t      ds                  qualified
     d     bytes_in                  10i 0
     d     bytes_out                 10i 0
     d     hold_cnt                  10u 0

     /* JIDF0100 Format */
     d jidf0100_t      ds                  qualified
     d     job_name                  10a
     d     user_name                 10a
     d     job_num                    6a
     d     int_job_id                16a
     d                                2a
     d     thd_ind                   10i 0
     d     thd_id                     8a

     /* Prototype of QTHMCTLT */
     d control_thread  pr                  extpgm('QTHMCTLT')
     d     receiver                        likeds(ctlt0100_t)
     d     rcv_len                   10i 0
     d     rcv_fmt                    8a
     d     job_thd_id                      likeds(jidf0100_t)
     d     id_fmt                     8a
      *
      * The action to be taken against the thread.
      *   1 = Hold thread
      *   2 = Release thread
      *   3 = End thread
      *
      *
     d     action                    10i 0
     d     error_code                      likeds(qusec_t)

     d rtn             ds                  likeds(ctlt0100_t)
     d rtn_len         s             10i 0 inz(%size(rtn))
     d rtn_fmt         s              8a   inz('CTLT0100')
     d job_thd_id      ds                  likeds(jidf0100_t)
     d id_fmt          s              8a   inz('JIDF0100')
     d act             s             10i 0 inz(1)
     d ec              ds                  likeds(qusec_t)

      /free
           rtn.bytes_in = %size(rtn);
           ec.bytes_in  = %size(ec);
           // init job_thd_id
           job_thd_id = *allx'00';
           job_thd_id.int_job_id = *blanks;
             // set job_name, user_name, job_num, and thd_id fields

           // hold the target thread within the target job
           control_thread( rtn
                         : rtn_len
                         : rtn_fmt
                         : job_thd_id
                         : id_fmt
                         : act
                         : ec );
           *inlr = *on;
      /end-free
