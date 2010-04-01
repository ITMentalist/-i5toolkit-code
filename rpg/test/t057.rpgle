
      /if defined(*crtbndrpg)
     h  dftactgrp(*no)
      /endif

      /copy mih52
     d tmpl            ds                  likeds(crtinx_tmpl_t)
     d                                     based(tmpl_ptr)
     d tmpl_ptr        s               *
     d tmpl_len        s             10i 0
     d inx             s               *
     d optlist         ds                  likeds(inx_option_list_t)
     d                                     based(opt_ptr)
     d len_off         ds                  likeds(inx_entry_length_offset_t)
     d                                     based(pos_ptr)
     d opt_ptr         s               *
     d pos_ptr         s               *
     d entry           s             32a
     d inx_attr        ds                  likeds(matinxat_tmpl_t)
     d                                     based(inx_attr_ptr)
     d inx_attr_ptr    s               *
     d mod_opt         ds                  likeds(modinx_tmpl_t)

      /free
           tmpl_len = %size(crtinx_tmpl_t);
           tmpl_ptr = %alloc(tmpl_len);
           propb(tmpl_ptr : x'00' : tmpl_len);
           tmpl.bytes_in = tmpl_len;
           tmpl.obj_type = x'0E01';
           tmpl.obj_name = 'NIHAO';
           tmpl.crt_opt  = x'40000000';
           tmpl.spc_size = x'010000';
           tmpl.init_spc_val = x'00';
           tmpl.perf_cls = x'01000000';
           tmpl.ext_offset = 0;
           tmpl.inx_attr = x'70';
           tmpl.arg_len  = 32;
           tmpl.key_len  = 8;
           // create index NIHAO
           crtinx(inx : tmpl_ptr);

           // insert a couple of entries into NIHAO
           entry = 'OBJD0200'
                   + '00010002'
                   + 'abcdABCD'
                   + 'ooooPPPP';
           opt_ptr = %alloc(10);
           // 注意 0001 适用于 non-keyed index
           optlist.rule_opt   = x'0002'; // insert with replacement
           optlist.arg_len    = 32;
           optlist.arg_offset = 0;
           optlist.occ_cnt    = 1;
           insinxen(inx : %addr(entry) : opt_ptr);
             // on successful insersion, OPTLIST.RTN_CNT is set to 1

           entry = 'OBJD0400'
                   + '00080002'
                   + 'xxxxYYYY'
                   + 'zzzzQQQQ';
           insinxen(inx : %addr(entry) : opt_ptr);

           // try to find out the entry with key value 'OBJD0200'
           opt_ptr = %realloc(opt_ptr : 14);
           optlist.rule_opt   = x'0001'; // look for an equal entry
           optlist.arg_len    = 8;
           optlist.arg_offset = 0;
           optlist.occ_cnt    = 1;
           entry = 'OBJD0200';     // specify key value

           fndinxen( %addr(entry)
                   : inx
                   : opt_ptr
                   : %addr(entry) );
           if optlist.rtn_cnt > 0;
               dsply 'index entry found' '' entry;
           endif;

           dealloc opt_ptr;

           // retrieve index attributes
           tmpl_len = %size(matinxat_tmpl_t);
           inx_attr_ptr = %alloc(tmpl_len);
           inx_attr.bytes_in = tmpl_len;
           matinxat(inx_attr_ptr : inx);
             // INX_ATTR.ENTRIES_INSERTED = 2
             // INX_ATTR.ENTRIES_REMOVED = 0
             // INX_ATTR.FIND_OPERATIONS = 1

           // modify index NIHAO
           mod_opt.mod_sel  = x'40'; // modify immediate update attr
           mod_opt.new_attr = x'00'; // do not immediate update
           mod_opt.reserved = x'0000';
           modinx(inx : %addr(mod_opt));

           dealloc inx_attr_ptr;

           // destroy index NIHAO
           desinx(inx);

           dealloc tmpl_ptr;
           *inlr = *on;
      /end-free
