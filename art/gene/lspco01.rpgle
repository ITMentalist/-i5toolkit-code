     /**
      * @file lspco01.rpgle
      *
      * Article ID: LSPCO
      */

     h dftactgrp(*no) bnddir('QC2LE')

      /if defined(HAVE_I5TOOLKIT)
      /copy mih-pgmexec
      /copy ts
      /else
     /**
      * @BIF _MODASA (Modify Automatic Storage Allocation (MODASA))
      *
      * @remark Note that unlike MI instruction MODASA, builtin
      *         _MODASA cannot be used to truncate ASF. Passing a
      *         negative value to _MODASA will raise a Scalar Value
      *         Invalid exception (3203)
      */
     d modasa          pr              *   extproc('_MODASA')
     d     mod_size                  10u 0 value
      * Allocate Teraspace heap storage
     d ts_malloc       pr              *   extproc('_C_TS_malloc')
     d     size                      10i 0 value
      * Returns a space pointer addressing the System Entry Point Table (SEPT)
     d sysept          pr              *   extproc('_SYSEPT')
      /endif
      * System built-in _LSPCO (Load Space Origin)
     d lspco           pr              *   extproc('_LSPCO')
     d     spp                         *   value
      * Display the content of an input MI pointer
     d dsp_ptr         pr
     d                                 *

     d a               s             80a   based(a@)
     d origin@         s               *
     d i_static        s             80a   inz('i static')

      /free
           // [x] Apply _LSPCO to a space pointer addressing
           //     a space object
           a@ = sysept();
           origin@ = lspco(a@);
           dsp_ptr(origin@);

           // [x] Apply _LSPCO to a space pointer addressing
           //     the SLS automatic stack
           a@ = modasa(%size(a));
           origin@ = lspco(a@);
           dsp_ptr(origin@);

           // [x] Apply _LSPCO to a space pointer addressing
           //     the static storage
           a@ = %addr(i_static);
           origin@ = lspco(a@);
           dsp_ptr(origin@);

           // [x] Apply _LSPCO to a space pointer addressing
           //     the SLS heap stroage
           a@ = %alloc(%size(a@)); 
           origin@ = lspco(a@);
           dsp_ptr(origin@);

           // [x] Apply _LSPCO to a space pointer addressing
           //     the Teraspace heap
           a@ = ts_malloc(80);
           origin@ = lspco(a@);
           dsp_ptr(origin@);

           *inlr = *on;
      /end-free

     p dsp_ptr         b
      * cvthc()
     d cvthc           pr                  extproc('cvthc')
     d                                1a   options(*varsize)
     d                                1a   options(*varsize)
     d                               10u 0 value

     d dsp_ptr         pi
     d   ptr@                          *

     d ptr_addr@       s               *
     d                 ds                  based(ptr_addr@)
     d hi8                            8a   
     d lo8                            8a
     d hi16            s             16a
     d lo16            s             16a

      /free
           ptr_addr@ = %addr(ptr@);
           cvthc(hi16:hi8:16);
           cvthc(lo16:lo8:16);
           dsply hi16 '' lo16;
      /end-free
     p                 e
