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
/* @file wrtusrspc.clp                                                        */
/*                                                                            */
/* Test of MI Portal. This OPM CL program write 32 bytes to                   */
/* a *USRSPC object via MI Portal. MI instructions and MI                     */
/* Portal support routines used in this program are the                       */
/* following:                                                                 */
/*  - RSLVSP2                                                                 */
/*  - SETSPPFP                                                                */
/*  - WRITE_ADDR                                                              */
/*  - ADDSPP                                                                  */
/*                                                                            */
/* @pre A *USRSPC *LIBL/AUG25 should be created before running                */
/*        this program. Here's a sample command:                              */
/*        CALL PGM(QUSCRTUS)                                                  */
/*             PARM('AUG25     *CURLIB' 'NOOTBOOK' X'00001000' X'00'          */
/*                  '*CHANGE' 'A nootbook')                                   */
/* @remark To examine data written into the target *USRSPC, use one of the    */
/*         DMPxxx commands. For example, DMPOBJ AUG25 *USRSPC.                */
/******************************************************************************/

             PGM        PARM(&MSG)
             DCL        VAR(&MSG) TYPE(*CHAR) LEN(32)
             DCL        VAR(&LEN) TYPE(*INT) LEN(4) VALUE(32)
             DCL        VAR(&RTMPL) TYPE(*CHAR) LEN(34)
             DCL        VAR(&OBJTYP) TYPE(*CHAR) STG(*DEFINED) +
                          LEN(2) DEFVAR(&RTMPL)
             DCL        VAR(&OBJNAM) TYPE(*CHAR) STG(*DEFINED) +
                          LEN(30) DEFVAR(&RTMPL 3)
             DCL        VAR(&RAUTH) TYPE(*CHAR) STG(*DEFINED) LEN(2) +
                          DEFVAR(&RTMPL 33)
             DCL        VAR(&INSTINX) TYPE(*INT) LEN(2) VALUE(3)
             DCL        VAR(&SYP) TYPE(*CHAR) LEN(16)
             DCL        VAR(&SPP) TYPE(*CHAR) LEN(16)
             DCL        VAR(&NOW) TYPE(*CHAR) LEN(20)

 RSLVSP:     CHGVAR     VAR(&OBJTYP) VALUE(X'1934')
             CHGVAR     VAR(&OBJNAM) VALUE('AUG25')
             CHGVAR     VAR(&RAUTH) VALUE(X'0000')
             CALL       PGM(MIPORTAL) PARM(&INSTINX &SYP &RTMPL) /* +
                          Resolve the system pointer to target +
                          *USRSPC */
 SETSPPFP:   CHGVAR     VAR(&INSTINX) VALUE(7)
             CALL       PGM(MIPORTAL) PARM(&INSTINX &SPP &SYP) /* +
                          Retrieve the space pointer addressing the +
                          associated space of *USRSPC AUG25 */
 WRTSCP:     CHGVAR     VAR(&INSTINX) VALUE(9)
             CALL       PGM(MIPORTAL) PARM(&INSTINX &SPP &MSG &LEN) +
                          /* Write &MSG into *USRSPC */
             RTVSYSVAL  SYSVAL(QDATETIME) RTNVAR(&NOW)
             CHGVAR     VAR(&INSTINX) VALUE(10)
             CALL       PGM(MIPORTAL) PARM(&INSTINX &SPP &SPP &LEN) +
                          /* Increment the offset value of &SPP by +
                          32 */
             CHGVAR     VAR(&LEN) VALUE(20)
             CHGVAR     VAR(&INSTINX) VALUE(9)
             CALL       PGM(MIPORTAL) PARM(&INSTINX &SPP &NOW &LEN) +
                          /* Write the current timestamp */
 END:
             ENDPGM
