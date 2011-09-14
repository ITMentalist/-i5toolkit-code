/******************************************************************************/
/* This file is part of i5/OS Programmer's Toolkit.                           */
/*                                                                            */
/* Copyright (C) 2010, 2011  Junlei Li (李君磊).                               */
/*                                                                            */
/* i5/OS Programmer's Toolkit is free software: you can redistribute it       */
/* and/or modify it under the terms of the GNU General Public License as      */
/* published by the Free Software Foundation, either version 3 of the         */
/* License, or (at your option) any later version.                            */
/*                                                                            */
/* i5/OS Programmer's Toolkit is distributed in the hope that it will be      */
/* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of     */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU          */
/* General Public License for more details.                                   */
/*                                                                            */
/* You should have received a copy of the GNU General Public License          */
/* along with i5/OS Programmer's Toolkit.  If not, see                        */
/* <http://www.gnu.org/licenses/>.                                            */
/******************************************************************************/

/******************************************************************************/
/* @file cmdline.clp                                                          */
/*                                                                            */
/* Test of MI Portal.                                                         */
/* MI instructions and MI                                                     */
/* Portal support routines used in this program are the                       */
/* following:                                                                 */
/*  - RSLVSP2                                                                 */
/*  - SETSPPFP                                                                */
/*  - WRITE_TO_ADDR                                                           */
/*  - RSLVSP2_H                                                               */
/*  - CALLPGMV                                                                */
/******************************************************************************/

             PGM
             DCL        VAR(&SPC555) TYPE(*CHAR) LEN(16) /* SYP TO +
                          1934 SPACE SPC555 */
             DCL        VAR(&SPP) TYPE(*CHAR) LEN(16) /* SPP */
             DCL        VAR(&PGMPTR) TYPE(*CHAR) LEN(16) /* SYP TO +
                          API QUSCMDLN */
             DCL        VAR(&N) TYPE(*CHAR) LEN(1)

 RSLVOPT:    CALL       PGM(MIPORTAL) PARM(X'0003' &SPC555 +
                          X'1934E2D7C3F5F5F54040404040404040404040404+
                          040404040404040404040400000')
             CALL       PGM(MIPORTAL) PARM(X'0007' &SPP &SPC555)
             CALL       PGM(MIPORTAL) PARM(X'0009' &SPP +
                          X'0201D8E4E2C3D4C4D3D5404040404040404040404+
                          040404040404040404040400000' X'00000022')
 RSLVSP2_H:  CALL       PGM(MIPORTAL) PARM(X'0013' &PGMPTR &SPP)
 CALLPGMV:   CALL       PGM(MIPORTAL) PARM(X'0015' &PGMPTR &N +
                          X'00000000')
             ENDPGM
