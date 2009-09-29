# This file is part of i5/OS Programmer's Toolkit.
# 
# Copyright (C) 2009  Junlei Li (李君磊).
# 
# i5/OS Programmer's Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# i5/OS Programmer's Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with i5/OS Programmer's Toolkit.  If not, see <http://www.gnu.org/licenses/>.

#
# makefile of mic
#

% : %.mi
	$(MIC) $(MIFLAGS) -o$@ $<

% : %.emi
	$(MIC) $(MIFLAGS) -o$@ $<

MIC=mic
MIFLAGS=-v -q'*list' -q'*replace' -q'*xref' -I. -L$(OUTPUTDIR)

ifeq ($(OS400), yes)
	MAKE=gmake
	CC=icc
	CXX=icc -+v
	RM=del
else
	MAKE=make
	CC=gcc
	CXX=g++
	RM=rm
endif

export MAKE
export CC
export CXX
export RM

ifndef CC
	CC=gcc
endif

ifndef CXX
	CXX=g++
endif

CFLAGS=-g -I.
CXXFLAGS=-g -I.

TARGETS=dspidxd rtvidxd

ifeq ($(OS400), yes)
all: $(TARGETS)
else
all: $(TARGETS)
endif
	@echo "that's all!"

clean:
	$(RM) $(TARGETS)

cmd_pnlgrp:
	@echo "attention: compiling CL command and panel-groups ..."
	system "CRTPNLGRP PNLGRP(I5TOOLKIT/IDXHLP) SRCFILE(LS2008/UIM) SRCMBR(*PNLGRP) INCFILE(*SRCFILE) REPLACE(*YES)"
	system "CRTPNLGRP PNLGRP(I5TOOLKIT/DSPIDXD) SRCFILE(LS2008/UIM) SRCMBR(*PNLGRP) INCFILE(*SRCFILE) REPLACE(*YES)"
	system "CRTCMD CMD($(OUTPUTDIR)/DSPIDXD) PGM($(OUTPUTDIR)/DSPIDXD) SRCFILE(LS2008/DEC) SRCMBR(DSPIDXD) HLPPNLGRP($(OUTPUTDIR)/IDXHLP) HLPID('HLP/IDXD')"
