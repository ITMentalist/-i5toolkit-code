     /**
      * @file cmpla01.rpgle
      */
     d i_main          pr                  extpgm('CMPLA01')
     d   ptra@                         *
     d   ptrb@                         *
     d   rtn                          1a

     d i_main          pi
     d   ptra@                         *
     d   ptrb@                         *
     d   rtn                          1a

STMT  /free
NUM:       select;
16         when ptra@ > ptrb@; // GT
17             rtn = 'G';
18         when ptra@ < ptrb@; // LT
19             rtn = 'L';
20         when ptra@ = ptrb@; // EQ
21             rtn = 'E';
22         other;              // UNEQ
23             rtn = 'U';
24         endsl;

26         *inlr = *on;
      /end-free
