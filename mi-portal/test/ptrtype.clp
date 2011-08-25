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
/* @file ptrtype.clp                                                          */
/*                                                                            */
/* Test of MI Portal.                                                         */
/*                                 MI instructions and MI                     */
/* Portal support routines used in this program are the                       */
/* following:                                                                 */
/*  - NEW_PTR                                                                 */
/*  - CMPPTRT                                                                 */
/******************************************************************************/

             PGM
             DCL        VAR(&R) TYPE(*INT) LEN(4) VALUE(0)
             DCL        VAR(&T) TYPE(*CHAR) LEN(1) VALUE(X'00')
             DCL        VAR(&PTR) TYPE(*CHAR) LEN(16)
             CALL       PGM(MIPORTAL) PARM(X'000F' &PTR)
             CALL       PGM(MIPORTAL) PARM(X'0010' &PTR &T &R)
             ENDPGM
