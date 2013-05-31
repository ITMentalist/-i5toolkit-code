     /**
      * @file lastu.rpgle
      *
      * Change the last-used date attribute of an object.
      *
      * Parameters:
      *  - CHAR(20) qualified object name. e.g. 'OBJNAME   *LIBL     '
      *  - CHAR(10) object type. e.g. '*USRSPC   '
      *  - CHAR(8) date in form of 'MMDDYYYY'
      *
      * @remark Make sure that the LASTU program uses a unique
      *         activation group.
      */

      /if defined(*crtbndrpg)
     h dftactgrp(*no) actgrp('LASTU')
      /endif

      /copy mih-ptr
      /copy mih-undoc
      /copy mih-spc

      * Qualified objat name
     d qual_obj_t      ds                  qualified
     d   obj                         10a
     d   lib                         10a

      * Propotype of the main procedure
     d i_main          pr                  extpgm('LASTU')
     d   obj                               likeds(qual_obj_t)
     d   obj_type                    10a
     d   last_used_dt                 8a

      * Prototype of procedure rslv_obj()
     d rslv_obj        pr              n
     d   obj                               likeds(qual_obj_t)
     d   obj_type                    10a
     d   obj@                          *

      * Prototype of the QWCCVTDT API
     d QWCCVTDT        pr                  extpgm('QWCCVTDT')
     d   in_fmt                      10a
     d   in_var                       1a   options(*varsize)
     d   out_fmt                     10a
     d   out_var                      1a   options(*varsize)
     d   ec                           8a   options(*varsize)

     d mdyy_fmt        s             10a   inz('*MDYY')
     d dts_fmt         s             10a   inz('*DTS')
     d mdyy_date       s             17a
     d sys_ts          ds
     d STAMP2                         2a   overlay(sys_ts:1)
     d ec              s              8a   inz(*allx'00')
     d obj@            s               *
     d mod_opt         s             64a

     d i_main          pi
     d   obj                               likeds(qual_obj_t)
     d   obj_type                    10a
     d   last_used_dt                 8a

      /free
           // [1] Resolve target MI object
           if not rslv_obj(obj : obj_type : obj@);
               // Error handling
               *inlr = *on;
               return;
           endif;

           // [2] Convert input date value to 8-byte system time-stamp
           %subst(mdyy_date:1:8) = last_used_dt;
           %subst(mdyy_date:9:9) = '200000000'; // 20:00:00
           QWCCVTDT( mdyy_fmt
                   : mdyy_date
                   : dts_fmt
                   : sys_ts
                   : ec );

           // [3] Modify the last-used date of target MI object
           mod_opt = *allx'00';
           %subst(mod_opt:1:1) = x'10';
           %subst(mod_opt:17:1) = x'40';
           %subst(mod_opt:27:2) = STAMP2;
           mods2(obj@:mod_opt); // STMT NUM=940

           *inlr = *on;
      /end-free

     p rslv_obj        b

      * Prototype of the QLICVTTP API
     d QLICVTTP        pr                  extpgm('QLICVTTP')
     d   cvn                         10a
     d   sym_type                    10a
     d   mi_type                      2a
     d   ec                           8a

     d LIBL            c                   '*LIBL'
     d LIB_QTEMP       c                   'QTEMP'
     d ec              s              8a   inz(*allx'00')
     d cvn             s             10a   inz('*SYMTOHEX')
     d mi_type         s              2a
     d ctx             s               *
     d rtn             s               n   inz(*on)

     d rslv_obj        pi              n
     d   obj                               likeds(qual_obj_t)
     d   obj_type                    10a
     d   obj@                          *

      /free
           // [1.1] Convert symbolic object type to hex MI object type
           QLICVTTP( cvn
                   : obj_type
                   : mi_type
                   : ec );

           // [1.2] Resolve target MI object
           monitor;
               if obj.lib = LIBL;
                   rslvsp_tmpl.obj_type = mi_type;
                   rslvsp_tmpl.obj_name = obj.obj;
                   rslvsp2(obj@ : rslvsp_tmpl);
               else;
                   if obj.lib = LIB_QTEMP;
                       ctx = qtempptr();
                   else;
                       rslvsp_tmpl.obj_type = x'0401';
                       rslvsp_tmpl.obj_name = obj.lib;
                       rslvsp2(ctx : rslvsp_tmpl);
                   endif;
                   rslvsp_tmpl.obj_type = mi_type;
                   rslvsp_tmpl.obj_name = obj.obj;
                   rslvsp4(obj@ : rslvsp_tmpl : ctx);
               endif;
           on-error;
               rtn = *off;
           endmon;

           return rtn;
      /end-free
     p                 e
