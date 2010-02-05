/* This file is part of i5/OS Programmer's Toolkit. */
/*  */
/* Copyright (C) 2010  Junlei Li (李君磊). */
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
/** @file dspqd.cmd */

             CMD        PROMPT('Display Queue Description (DSPQD)')

/* queue name */
             PARM       KWD(Q) TYPE(Q_NAME) MIN(1) KEYPARM(*YES) +
                          PROMPT('Queue object')
             PARM       KWD(QTYPE) TYPE(*NAME) LEN(10) RSTD(*YES) +
                          DFT(*DTAQ) SPCVAL((*DTAQ) (*USRQ)) MIN(0) +
                          PROMPT('Queue type')

/* qualifiers */
 Q_NAME:     QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*CURLIB) (*LIBL)) PROMPT('Library +
                          name')

/* EOF */
