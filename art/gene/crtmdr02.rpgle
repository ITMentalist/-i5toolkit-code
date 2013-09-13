     /**
      * @file crtmdr02.rpgle
      *
      * @remark Offset values used here are VRM540 specific.
      */

     h dftactgrp(*no) bnddir('QC2LE')

     fQSYSPRT   o    f  528        disk
     d prt_hdr         s             75a   inz('Built-in Name         +
     d                                     Code-1  Code-2  Code-3  +
     d                                     Code-4  Code-5  CC    +
     d                                     EE(Hex)')
     d bif_info        ds
     d   bif_name                    20a
     d   bif_code                     5p 0 dim(5)
     d   bif_CC                       6a
     d   bif_EE                       6a

     d obj@            s               *
     d PSTR69_NAME_SECT_OFFSET...
     d                 c                   x'22B0'
      * Prototype string 69 of *PGM QWXCRTMD
     d pstr69          ds                  based(pstr69@)
      * Offset/length section, length = hex 22B0
     d   offlen_sect               8880a
      * Name section, length = hex (39A0 - 22B0) = hex 16F0 (5872)
     d   name_sect                 5872a
      * Code section, length = hex (6EA4 - 39A0) = hex 3504 (13572)
     d   code_sect                13572a

      * Determine the starting address of the encapsulated part of *PGM QWXCRTMD
     d determine_base_addr...
     d                 pr
      * Locate PSTR-69
     d locate_pstr69   pr
      * Parse system built-in information in PSTR-69
     d parse_builtins  pr

      /free
           determine_base_addr();
           locate_pstr69();
           parse_builtins();

           *inlr = *on;
      /end-free

      * Output specifications
     oQSYSPRT   e            HEADERREC
     o                       prt_hdr

     oQSYSPRT   e            SYSBIFREC
     o                       bif_name
     o                       bif_code(1)         28
     o                       bif_code(2)         36
     o                       bif_code(3)         44
     o                       bif_code(4)         52
     o                       bif_code(5)         60
     o                       bif_CC              68
     o                       bif_EE              74

     /**
      * Procedure determine_base_addr()
      *
      * @post obj@. Address of start of the encapsulated part of *PGM QWXCRTMD
      */
     p determine_base_addr...
     p                 b
     d determine_base_addr...
     d                 pi

     d spc_crtmd       s             20a   inz('CRTMD     QTEMP')
     d qusptrus        pr                  extpgm('QUSPTRUS')
     d   qual_name                   20a
     d   spp@                          *
      /free
           qusptrus(spc_crtmd : obj@);
      /end-free
     p                 e

     /**
      * Procedure locate_pstr69()
      *
      * @pre  obj@.
      * @post pstr69@. Space pointer addressing PSTR-69
      */
     p locate_pstr69   b

      * EPA header
     d epa_header      ds                  based(epa_header@)
     d   osg_addr                     8a   overlay(epa_header:81)
      * Porgram header
     d pgm_header      ds                  based(pgm_header@)
     d   acthdr_addr                  8a   overlay(pgm_header:25)
      * Activation header
     d act_header      ds                  based(act_header@)
     d   ssflst_addr                  8a   overlay(act_header:113)
      * Program SSF list
     d ssf_list        ds                  based(ssf_lst@)
     d   pstrlst_addr                 8a   overlay(ssf_list:65)
      * PSTR-69
     d pstr_t          ds                  qualified
     d   pstr_addr                    8a
     d   pstr_length                 10u 0
     d   pstr_mssf                   10u 0
     d                                8a
     d pstr_list       ds                  likeds(pstr_t)
     d                                     dim(80)
     d                                     based(pstr_list@)

     d                 ds
     d offset                        10u 0 inz(0)
     d offlo3                         3a   overlay(offset:2)

     d locate_pstr69   pi

      /free
           epa_header@ = obj@ + 32;  // Locate EPA header
           offlo3 = %subst(osg_addr:6:3);

           pgm_header@ = obj@ + offset;
           offlo3 = %subst(acthdr_addr:6:3);

           act_header@ = obj@ + offset;
           offlo3 = %subst(ssflst_addr:6:3);

           ssf_lst@ = obj@ + offset;
           offlo3 = %subst(pstrlst_addr:6:3);

           pstr_list@ = obj@ + offset;
           offlo3 = %subst(pstr_list(69).pstr_addr:6:3);

           pstr69@ = obj@ + offset;
           return;
      /end-free
     p locate_pstr69   e

     /**
      * Procedure parse_builtins()
      * Parse system built-in information in PSTR-69
      *
      * @pre pstr69@
      */
     p parse_builtins  b
     d parse_builtins  pi

      * Prototype of cvthc()
     d cvthc           pr                  extproc('cvthc')
     d                                1a   options(*varsize)
     d                                 *   value
     d                               10u 0 value

      * Offset/length entry
     d offlen_t        ds                  based(offlen@)
     d   name_offset                 10u 0
     d   name_length                  5u 0
     d   code_offset                  5u 0
     d   num_code                     5u 0
     d   EE                           5u 0
     d offlen_ent_len  s             10u 0 inz(%size(offlen_t))

     d NAME_SECT_OFF   s             10u 0 inz(x'22B0')
     d CODE_SECT_OFF   s             10u 0 inz(x'39A0')
     d name_sect@      s               *
     d code_sect@      s               *
     d offset          s             10u 0 inz(0)
     d code_inx        s              5u 0
     d name            s             20a   based(name@)
     d code            s             10u 0 based(code@)

      /free
           except HEADERREC;
           name_sect@ = pstr69@ + NAME_SECT_OFF;
           code_sect@ = pstr69@ + CODE_SECT_OFF;

           // dow condition: end of offlen_sect
           for offset = 0
               to PSTR69_NAME_SECT_OFFSET - offlen_ent_len
               by offlen_ent_len;

               offlen@ = pstr69@ + offset;
               if name_length = 0;
                   iter;
               endif;

               clear bif_info;

               // Determine system built-in name
               name@ = name_sect@ + name_offset;
               bif_name = %subst(name:1:name_length);

               // Determine system built-in code values
               code_inx = 1;
               code@ = code_sect@ + code_offset * 4;

               // if EE is NOT hex 0000, record CC, EE fields
               if EE <> 0;
                   bif_CC = %char(code_offset);
                   cvthc(bif_EE:%addr(EE):4);
                   except SYSBIFREC;
                   iter;
               endif;

               // Parse code values
               dow code_inx <= num_code;
                   // New code value
                   bif_code(code_inx) = code;

                   // Next code value
                   code_inx += 1;
                   code@ += 4;
               enddo;

               except SYSBIFREC;
           endfor;
      /end-free
     p                 e
