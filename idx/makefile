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

TARGETS=dspidxd

ifeq ($(OS400), yes)
all: $(TARGETS) cmd_pnlgrp
else
all: $(TARGETS)
endif
	@echo "that's all!"

mic.o: stmt.hpp builtin.hpp

mic: mic.o mic-main.o
	$(CXX) -o $@ $^

clean:
	$(RM) $(TARGETS)

cmd_pnlgrp:
	@echo "attention: compiling CL command and panel-groups ..."
#	system "CRTPNLGRP PNLGRP($(OUTPUTDIR)/MICHLP) SRCFILE(LS2008/DEC) SRCMBR(*PNLGRP)"
#	system "CRTCMD CMD($(OUTPUTDIR)/MIC) PGM($(OUTPUTDIR)/MIC) SRCFILE(LS2008/DEC) SRCMBR(MIC) HLPPNLGRP($(OUTPUTDIR)/MICHLP) HLPID('HLP/MIC')"
