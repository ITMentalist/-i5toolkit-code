     /**
      * @file tst_animal.rpgle
      *
      */
     h dftactgrp(*no)

      /copy mih-ptr
      /copy mih-pgmexec

     d spc_ptr         s               *
     d methods         ds                  based(spc_ptr)
     d   chase                         *   procptr
     d   taste                         *   procptr
     d   no_more                       *
     d   eye_catcher                 16a
     d                 ds
     d proc_ptr                        *   procptr
     d dta_ptr                         *   overlay(proc_ptr)
     d ssf             s               *
     d argds           ds
     d   insptr                        *   procptr
     d   argv                          *   dim(2)
     d   args                          *   dim(3) overlay(argds)
     d pgm             s               *
     d dta_name        s             32a
     d food            s             16a   inz('Meat bones')

      /free
           // [1] Resolve external data object ANIMAL-METHODS
           dta_name = 'ANIMAL-METHODS';
           monitor;
               rslvdp2(dta_ptr : dta_name);
           on-error;
               // Error handling
           endmon;

           // [2] Obtain a space pointer from dta_ptr so that
           // instruction pointers in data struture @var methods
           // become valid.
           spc_ptr = setsppfp(proc_ptr);

           // [3] Retrieve a system pointer to the program object
           // which exports instruction pointer @var chase
           pgm = rpg_setspfp(chase);  // Debug: ev %var(pgm)

           // [4] Invoke method Chase()
           insptr = chase;
           callpgmv(pgm : args : 1);

           // [5] Invoke method Taste()
           insptr  = taste;
           argv(1) = %addr(food);
           callpgmv(pgm : args : 2);

           *inlr = *on;
      /end-free
