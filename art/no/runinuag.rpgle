     /**
      * @file runinuag.rpgle
      *
      * Run a program in a user activation group
      * e.g.
      * CALL PGM(RUNINUAG) PARM(X'0000000000000038' 'A381      *LIBL')
      */

      /copy mih-ptr
      /copy mih-pgmexec
      /copy mih-undoc

     d objname_t       ds                  qualified
     d   obj                         10a
     d   lib                         10a

     /**
      * Prototype of RUNINUAG
      */
     d main_proc       pr                  extpgm('RUNINUAG')
     d   agp_mark                    20u 0
     d   pgm                               likeds(objname_t)
      * Up to 253 parameters to the callee program
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a
     d                                1a

     d main_proc       pi
     d   agp_mark                    20u 0
     d   pgm                               likeds(objname_t)
     d   x001                         1a
     d   x002                         1a
     d   x003                         1a
     d   x004                         1a
     d   x005                         1a
     d   x006                         1a
     d   x007                         1a
     d   x008                         1a
     d   x009                         1a
     d   x010                         1a
     d   x011                         1a
     d   x012                         1a
     d   x013                         1a
     d   x014                         1a
     d   x015                         1a
     d   x016                         1a
     d   x017                         1a
     d   x018                         1a
     d   x019                         1a
     d   x020                         1a
     d   x021                         1a
     d   x022                         1a
     d   x023                         1a
     d   x024                         1a
     d   x025                         1a
     d   x026                         1a
     d   x027                         1a
     d   x028                         1a
     d   x029                         1a
     d   x030                         1a
     d   x031                         1a
     d   x032                         1a
     d   x033                         1a
     d   x034                         1a
     d   x035                         1a
     d   x036                         1a
     d   x037                         1a
     d   x038                         1a
     d   x039                         1a
     d   x040                         1a
     d   x041                         1a
     d   x042                         1a
     d   x043                         1a
     d   x044                         1a
     d   x045                         1a
     d   x046                         1a
     d   x047                         1a
     d   x048                         1a
     d   x049                         1a
     d   x050                         1a
     d   x051                         1a
     d   x052                         1a
     d   x053                         1a
     d   x054                         1a
     d   x055                         1a
     d   x056                         1a
     d   x057                         1a
     d   x058                         1a
     d   x059                         1a
     d   x060                         1a
     d   x061                         1a
     d   x062                         1a
     d   x063                         1a
     d   x064                         1a
     d   x065                         1a
     d   x066                         1a
     d   x067                         1a
     d   x068                         1a
     d   x069                         1a
     d   x070                         1a
     d   x071                         1a
     d   x072                         1a
     d   x073                         1a
     d   x074                         1a
     d   x075                         1a
     d   x076                         1a
     d   x077                         1a
     d   x078                         1a
     d   x079                         1a
     d   x080                         1a
     d   x081                         1a
     d   x082                         1a
     d   x083                         1a
     d   x084                         1a
     d   x085                         1a
     d   x086                         1a
     d   x087                         1a
     d   x088                         1a
     d   x089                         1a
     d   x090                         1a
     d   x091                         1a
     d   x092                         1a
     d   x093                         1a
     d   x094                         1a
     d   x095                         1a
     d   x096                         1a
     d   x097                         1a
     d   x098                         1a
     d   x099                         1a
     d   x100                         1a
     d   x101                         1a
     d   x102                         1a
     d   x103                         1a
     d   x104                         1a
     d   x105                         1a
     d   x106                         1a
     d   x107                         1a
     d   x108                         1a
     d   x109                         1a
     d   x110                         1a
     d   x111                         1a
     d   x112                         1a
     d   x113                         1a
     d   x114                         1a
     d   x115                         1a
     d   x116                         1a
     d   x117                         1a
     d   x118                         1a
     d   x119                         1a
     d   x120                         1a
     d   x121                         1a
     d   x122                         1a
     d   x123                         1a
     d   x124                         1a
     d   x125                         1a
     d   x126                         1a
     d   x127                         1a
     d   x128                         1a
     d   x129                         1a
     d   x130                         1a
     d   x131                         1a
     d   x132                         1a
     d   x133                         1a
     d   x134                         1a
     d   x135                         1a
     d   x136                         1a
     d   x137                         1a
     d   x138                         1a
     d   x139                         1a
     d   x140                         1a
     d   x141                         1a
     d   x142                         1a
     d   x143                         1a
     d   x144                         1a
     d   x145                         1a
     d   x146                         1a
     d   x147                         1a
     d   x148                         1a
     d   x149                         1a
     d   x150                         1a
     d   x151                         1a
     d   x152                         1a
     d   x153                         1a
     d   x154                         1a
     d   x155                         1a
     d   x156                         1a
     d   x157                         1a
     d   x158                         1a
     d   x159                         1a
     d   x160                         1a
     d   x161                         1a
     d   x162                         1a
     d   x163                         1a
     d   x164                         1a
     d   x165                         1a
     d   x166                         1a
     d   x167                         1a
     d   x168                         1a
     d   x169                         1a
     d   x170                         1a
     d   x171                         1a
     d   x172                         1a
     d   x173                         1a
     d   x174                         1a
     d   x175                         1a
     d   x176                         1a
     d   x177                         1a
     d   x178                         1a
     d   x179                         1a
     d   x180                         1a
     d   x181                         1a
     d   x182                         1a
     d   x183                         1a
     d   x184                         1a
     d   x185                         1a
     d   x186                         1a
     d   x187                         1a
     d   x188                         1a
     d   x189                         1a
     d   x190                         1a
     d   x191                         1a
     d   x192                         1a
     d   x193                         1a
     d   x194                         1a
     d   x195                         1a
     d   x196                         1a
     d   x197                         1a
     d   x198                         1a
     d   x199                         1a
     d   x200                         1a
     d   x201                         1a
     d   x202                         1a
     d   x203                         1a
     d   x204                         1a
     d   x205                         1a
     d   x206                         1a
     d   x207                         1a
     d   x208                         1a
     d   x209                         1a
     d   x210                         1a
     d   x211                         1a
     d   x212                         1a
     d   x213                         1a
     d   x214                         1a
     d   x215                         1a
     d   x216                         1a
     d   x217                         1a
     d   x218                         1a
     d   x219                         1a
     d   x220                         1a
     d   x221                         1a
     d   x222                         1a
     d   x223                         1a
     d   x224                         1a
     d   x225                         1a
     d   x226                         1a
     d   x227                         1a
     d   x228                         1a
     d   x229                         1a
     d   x230                         1a
     d   x231                         1a
     d   x232                         1a
     d   x233                         1a
     d   x234                         1a
     d   x235                         1a
     d   x236                         1a
     d   x237                         1a
     d   x238                         1a
     d   x239                         1a
     d   x240                         1a
     d   x241                         1a
     d   x242                         1a
     d   x243                         1a
     d   x244                         1a
     d   x245                         1a
     d   x246                         1a
     d   x247                         1a
     d   x248                         1a
     d   x249                         1a
     d   x250                         1a
     d   x251                         1a
     d   x252                         1a
     d   x253                         1a

     d get_callx_mark  pr            20u 0
     d   agp_mark                    20u 0 value
     d resolve_callxx  pr              *   procptr
     d   act_mark                    20u 0 value

     d LIBL            c                   '*LIBL'
     d LIB_QTEMP       c                   'QTEMP'
     d ctx             s               *
     d callx_mark      s             20u 0
     d plist_ptr       s               *
     d plist           ds                  likeds(npm_plist_t)
     d                                     based(plist_ptr)
     d parm_desc_list  ds                  likeds(parm_desc_list_t)
     d                                     based(@parm_desc_list)
     d argc            s             10u 0
     d argv            s               *   dim(253)
     d                                     based(@argv)
     d i               s             10u 0
     d @arg            s               *
     d arg             s              8a   based(@arg)
     d callxx          s               *   procptr
     d callee          s               *
     d callxx_proc     pr                  extproc(callxx)
     d     pgm_ptr                     *
     d     argv                        *   dim(1) options(*varsize)
     d     argc                      10u 0 value

      /free
           // [1] Dequeue act-mark of *srvpgm CALLX by agp-mark
           callx_mark = get_callx_mark(agp_mark);
           if callx_mark = 0;  // Failed to find target UAG
               // Error handling
               *inlr = *on;
               return;
           endif;

           // [2] Resolve PROCPTR to proceture callxx()
           callxx = resolve_callxx(callx_mark);
           if callxx = *NULL;
               // Error handling
               *inlr = *on;
               return;
           endif;

           // [3] Resolve a SYP to callee program
           monitor;
               if pgm.lib = LIBL;
                   rslvsp_tmpl.obj_type = x'0201';
                   rslvsp_tmpl.obj_name = pgm.obj;
                   rslvsp2(callee : rslvsp_tmpl);
               else;
                   if pgm.lib = LIB_QTEMP;
                       ctx = qtempptr();
                   else;
                       rslvsp_tmpl.obj_type = x'0401';
                       rslvsp_tmpl.obj_name = pgm.lib;
                       rslvsp2(ctx : rslvsp_tmpl);
                   endif;
                   rslvsp_tmpl.obj_type = x'0201';
                   rslvsp_tmpl.obj_name = pgm.obj;
                   rslvsp4(callee : rslvsp_tmpl : ctx);
               endif;
           on-error;
               // Error handling
               *inlr = *on;
               return;
           endmon;

           // [4] Compose argument list to pass to callee
           plist_ptr = npm_plist();
           @parm_desc_list = plist.parm_desc_list;
           argc = parm_desc_list.argc - 2;
           @argv = %addr(plist.argvs) + 32;
           // for i = 1 to argc;
           //     @arg = argv(i);
           //     dsply i '' arg;
           // endfor;

           // [5] Call callee via CALLXX
           callxx_proc( callee : argv : argc );

           *inlr = *on;
      /end-free

     /**
      * Return the activation mark of *SRVPGM CALLX in
      * the target activation group.
      * @remark 0 is returned is target group is NOT found.
      */
     p get_callx_mark  b
     d do_deq          pr                  extpgm('QRCVDTAQ')
     d   q_name                      10a
     d   q_lib                       10a
     d   msg_len                      5p 0
     d   msg                         20u 0
     d   timeout                      5p 0
     d   key_order                    2a
     d   key_len                      3p 0
     d   key                         20u 0
     d   sender_len                   3p 0
     d   sender_info                  1a
     d   rmv_flag                    10a
     d   rcv_len                      5p 0
     d   deq_ec                       8a

     d DTAQ_NAME       s             10a   inz('USRAGP')
     d DTAQ_LIB        s             10a   inz('QTEMP')
     d msg_len         s              5p 0 inz(8)
     d key_len         s              3p 0 inz(8)
      * Do NOT wait!
     d timeout         s              5p 0 inz(0)
     d key_order       s              2a   inz('EQ')
     d sender_len      s              3p 0 inz(0)
     d sender_info     s              1a
      * Do NOT remove queue message
     d rmv_flag        s             10a   inz('*NO')
     d rcv_len         s              5p 0 inz(8)
     d deq_ec          s              8a   inz(x'0000000800000000')

     d act_mark        s             20u 0

     d get_callx_mark  pi            20u 0
     d   agp_mark                    20u 0 value

      /free
           do_deq( DTAQ_NAME
                 : DTAQ_LIB
                 : msg_len
                 : act_mark
                 : timeout
                 : key_order
                 : key_len
                 : agp_mark
                 : sender_len
                 : sender_info
                 : rmv_flag
                 : rcv_len
                 : deq_ec );
           if msg_len = 0;  // No such UAG!
               act_mark = 0;
           endif;

           return act_mark;
      /end-free
     p                 e

     /**
      * Resolve a procedure pointer to callxx() which
      * is exported by *SRVPGM CALLX.
      */
     p resolve_callxx  b
     d QleGetExpLong   pr                  extproc('QleGetExpLong')
     d   act_mark                    20u 0
     d   exp_id                      10i 0
     d   exp_name_len                10i 0
     d   exp_name                     1a   options(*varsize)
      * Pointer addressing the returned export
     d   exp_ptr                       *   procptr
      * Export type. 0=Not found, 1=procedure, 2=data
     d   exp_type                    10i 0
     d   ec                           8a

     d exp_id          s             10i 0 inz(1)
     d exp_name_len    s             10i 0 inz(0)
     d exp_name        s              1a
     d exp_ptr         s               *   procptr
     d exp_type        s             10i 0 inz(0)
     d ec              s              8a   inz(x'0000000800000000')

     d resolve_callxx  pi              *   procptr
     d   act_mark                    20u 0 value

      /free
           QleGetExpLong( act_mark
                        : exp_id
                        : exp_name_len
                        : exp_name
                        : exp_ptr
                        : exp_type
                        : ec );
           if exp_type = 0;
               return *null;
           endif;

           return exp_ptr;
      /end-free
     p                 e
