     /**
      * @file atmc03.rpgle
      *
      * Atomically increment each of one or more counters shared by
      * multiple threads.
      * @pre Create a hex 1934 space named CTRRA:
      *      CALL PGM(QUSCRTUS) +
      *        PARM('CTRARA    *CURLIB' 'USRARA' X'00000F00' +
      *          X'00' *USE 'Counter Space')
      */

     h dftactgrp(*no)

     d atmc03          pr                  extpgm('ATMC03')
     d   ctrinx                       5u 0 dim(16) options(*varsize)
     d   numinx                       5u 0
     d   incctr                      20i 0 dim(16) options(*varsize)

     /**
      * @BIF _SYNCSTG (Synchronize Shared Storage Accesses (SYNCSTG))
      */
     d syncstg         pr                  extproc('_SYNCSTG')
     d     action                    10u 0 value
     /**
      * @BIF _ATMCADD8 (Atomic Add (ATMCADD))
      */
     d atmcadd8        pr            20i 0 extproc('_ATMCADD8')
     d     sum_addend                20i 0
     d     augend                    20i 0 value
      *
     d rslvsp_tmpl     ds                  qualified
     d     obj_type                   2a
     d     obj_name                  30a
      * required authorization
     d     auth                       2a   inz(x'0000')
     /**
      * @BIF _RSLVSP2 (Resolve System Pointer (RSLVSP))
      */
     d rslvsp2         pr                  extproc('_RSLVSP2')
     d     obj                         *   procptr
     d     opt                       34a
     /**
      * @BIF _SETSPPFP (Set Space Pointer from Pointer (SETSPPFP))
      */
     d setsppfp        pr              *   extproc('_SETSPPFP')
     d     src_ptr                     *   value procptr

      * System pointer to hex 1934 space object USRDTAARA
     d spc@            s               *   procptr
     d counter         s             20i 0 based(spp@)
     d                                     dim(16)
     d one             s             20i 0 inz(1)
     d n               s              5u 0

     d atmc03          pi
     d   ctrinx                       5u 0 dim(16) options(*varsize)
     d   numinx                       5u 0
     d   incctr                      20i 0 dim(16) options(*varsize)

      /free
           // Resolve a SYSPTR the 1934 *LIBL/CTRARA
           rslvsp_tmpl.obj_type = x'1934';
           rslvsp_tmpl.obj_name = 'CTRARA';
           rslvsp2(spc@ : rslvsp_tmpl);
           spp@ = setsppfp(spc@);

           for n = 1 to numinx;
               // Increase @var counter_a by 1 atomically
               atmcadd8(counter(ctrinx(n)) : one);

               // Enforce ordering of shared storage operations
               syncstg(0);

               // Display the increased value of @var counter
               dsply ctrinx(n) '' counter(ctrinx(n));
           endfor;

           *inlr = *on;
      /end-free
