     /**
      * @file asa02.rpgle
      * ID: MODASA
      */
     h dftactgrp(*no)

      /if defined(HAVE_I5TOOLKIT)
      /copy mih-pgmexec
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
      /endif

     d auto_buf        s            256a   based(auto@)
      /free
           auto@ = modasa(%size(auto_buf));
           // @var auto_buf is now available for use

           *inlr = *on;
      /end-free
