     d i_main          pr                  extpgm('YY282')
     d    b2                          5i 0
     d    b4                         10i 0
     d    p8                          8p 2
     d    z16                        16s 5

     d i_main          pi
     d    b2                          5i 0
     d    b4                         10i 0
     d    p8                          8p 2
     d    z16                        16s 5

      /free
           b4 = b2 + 1;
           p8 = b2 + 1.56;
           z16= b2 + 1.56789;

           *inlr = *on;
      /end-free
