     d tmpl            ds                  qualified
     d     bi                        10i 0 inz(10)
     d     bo                        10i 0
     d     prc_num                    5u 0

     d opt             s              2a   inz(x'01DC')
     d ent_num         s              5u 0 inz(1)

     c                   call      'MIPORTAL'
     c                   parm                    ent_num
     c                   parm                    tmpl
     c                   parm                    opt
     c     'processors'  dsply                   tmpl.prc_num
     c                   seton                                        lr
