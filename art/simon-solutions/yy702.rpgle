     d n               s             10i 0
     d b               s               z
     d e               s               z

     c                   eval      b = %timestamp()
     c                   for       n = 1 to 100000
     c                   call      'QMNSBS'
     c                   parm                    sbs_name         10
     c                   parm                    ctlsbsd          10
     c                   parm                    ctlsbsdlib       10
     c                   endfor
     c                   eval      e = %timestamp()
     c                   eval      n = %diff(e:b:*ms)
     c     'ms'          dsply                   n
     c                   seton                                        lr
