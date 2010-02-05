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

/* file enqusrq.mi */
             CMD        PROMPT('Enqueue User Queue (ENQUSRQ)')

             PARM       KWD(Q) TYPE(Q_OBJ) MIN(1) PROMPT('Queue +
                          object') /* Parm1: queue object */
             PARM       KWD(KEY) TYPE(*CHAR) LEN(256) DFT(*NONE) +
                          SPCVAL((*NONE '')) MIN(0) VARY(*YES +
                          *INT2) CASE(*MIXED) INLPMTLEN(50) +
                          PROMPT('Key data') /* Parm2: key data */
             PARM       KWD(MSG) TYPE(*CHAR) LEN(5000) DFT(*NONE) +
                          SPCVAL((*NONE '')) VARY(*YES *INT2) +
                          CASE(*MIXED) INLPMTLEN(80) +
                          PROMPT('Message text') /* Parm3: message +
                          text */
             PARM       KWD(MSGLEN) TYPE(*DEC) LEN(5 0) DFT(0) +
                          PROMPT('Message text length')

 Q_OBJ:      QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*CURLIB) (*LIBL)) PROMPT('Library +
                          name')

