      * ii239.rpgle
     d jobi0600        ds
     d   ctrl_cancel                  1a   overlay(jobi0600:71)
     d len             s             10i 0 inz(328)

     c                   call      'QUSRJOBI'
     c                   parm                    jobi0600
     c                   parm                    len
     c                   parm      'JOBI0600'    fmt_name          8
     c                   parm      '*'           job_name         26
     c                   parm      *blanks       int_id           16
     c     'End Status'  dsply                   ctrl_cancel
     c                   seton                                        lr
