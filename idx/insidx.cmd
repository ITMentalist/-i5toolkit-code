/* This file is part of i5/OS Programmer's Toolkit. */
/*  */
/* Copyright (C) 2010  Junlei Li. */
/*  */
/* i5/OS Programmer's Toolkit is free software: you can redistribute it and/or modify */
/* it under the terms of the GNU General Public License as published by */
/* the Free Software Foundation, either version 3 of the License, or */
/* (at your option) any later version. */
/*  */
/* i5/OS Programmer's Toolkit is distributed in the hope that it will be useful, */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the */
/* GNU General Public License for more details. */
/*  */
/* You should have received a copy of the GNU General Public License */
/* along with i5/OS Programmer's Toolkit.  If not, see <http://www.gnu.org/licenses/>. */

/* @file insidx.cmd */

             CMD        PROMPT('Insert User Index')

             PARM       KWD(USRIDX) TYPE(OBJ_NAME) MIN(1) +
                          KEYPARM(*YES) PROMPT('User index')

             PARM       KWD(ENTRY) TYPE(*CHAR) LEN(2000) +
                          INLPMTLEN(50) PROMPT('Entry data')

             PARM       KWD(ENTLEN) TYPE(*INT4) REL(*LE 2000) +
                          PROMPT('Entry length')

             PARM       KWD(REPLACE) TYPE(*CNAME) LEN(1) RSTD(*YES) +
                          DFT(*YES) SPCVAL((*YES '1') (*NO '0')) +
                          PROMPT('Insert with replacement')

 OBJ_NAME:   QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')

/* EOF */
