      * Prototype of the WCBT1 program
     d pcsptr          pr                  extpgm('WCBT1')
     d   jobnam                      10a
     d   jobusr                      10a
     d   jobnum                       6a
     d   pcs@                          *
      * My prototype
     d me              pr                  extpgm('WCBT1B')
     d   jobnam                      10a
     d   jobusr                      10a
     d   jobnum                       6a
     d pcs@            s               *
     d me              pi
     d   jobnam                      10a
     d   jobusr                      10a
     d   jobnum                       6a
STMT  /free
18         pcsptr(jobnam : jobusr : jobnum : pcs@);
19         *inlr = *on;
      /end-free
