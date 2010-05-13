
     /**
      * @file t072.rpgle
      *
      * test of _RINZSTAT
      *
      * @remark _RINZSTAT only affects programs compiled with ALWRINZ(*YES).
      */

      /if defined(*crtbndrpg)
     h dftactgrp(*no)
      /endif

      /copy mih52

     d inv_tmpl_ptr    s               *
     d inv_tmpl        ds                  likeds(matinvat_selection_t)
     d                                     based(inv_tmpl_ptr)
     d ag_mark         ds                  likeds(matinvat_ag_mark_rcv_t)
     d mat_tmpl_ptr    s               *
     d mat_tmpl        ds                  likeds(mathsat_tmpl_t)
     d                                     based(mat_tmpl_ptr)
     d invid           ds                  likeds(invocation_id_t)
     d inz_tmpl        ds                  likeds(rinzstat_tmpl_t)
     d pgmptr          s               *
     d i_static        s             16a   inz('tommy')

     d i_main          pr                  extpgm('T072')
     d     inv_ptr                     *

     d i_main          pi
     d     inv_ptr                     *

      /free
           // get AG mark
           inv_tmpl_ptr = modasa(matinvat_selection_length);
           propb( inv_tmpl_ptr
                 : x'00'
                 : matinvat_selection_length );
           inv_tmpl.num_attr   = 1;
           inv_tmpl.flag1      = x'00';
           inv_tmpl.ind_offset = 0;
           inv_tmpl.ind_length = 0;
           inv_tmpl.attr_id    = 14;  // materialize AG mark
           inv_tmpl.flag2      = x'00';
           inv_tmpl.rcv_offset = 0;
           inv_tmpl.rcv_length = 4;
           matinvat(%addr(ag_mark) : inv_tmpl_ptr);

           // retrieve SYP to the current program
           inv_tmpl.attr_id = 6;   // system pointer to pgm
           inv_tmpl.rcv_length = 16;
           matinvat(%addr(pgmptr) : inv_tmpl_ptr);

           i_static = 'Julian';
           dsply 'i_static' '' i_static;

           // reinitialize static storage
           inz_tmpl.agp_mark = ag_mark.ag_mark;
           inz_tmpl.pgm      = pgmptr;
           rinzstat(inz_tmpl);
           dsply 'i_static' '' i_static;

           *inlr = *on;
      /end-free
