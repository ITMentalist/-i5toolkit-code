     d len             s             10i 0 inz(192)
     d jobi0200        ds           192    qualified
     d                               62a
     d   sbs_name                    10a

     d n               s             10i 0
     d b               s               z
     d e               s               z

     c                   eval      b = %timestamp()
     c                   for       n = 1 to 100000
     c                   call      'QUSRJOBI'
     c                   parm                    jobi0200
     c                   parm                    len
     c                   parm      'JOBI0200'    fmt               8
     c                   parm      '*'           job_name         26
     c                   parm      *BLANKS       int_jid          16
     c                   endfor
     c                   eval      e = %timestamp()
     c                   eval      n = %diff(e:b:*ms)
     c     'ms'          dsply                   n
     c                   seton                                        lr
