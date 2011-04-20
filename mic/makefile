# This file is part of i5/OS Programmer's Toolkit.
# 
# Copyright (C) 2010, 2011  Junlei Li (李君磊).
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

MAKERULES=rules.mk
CLEFLAGS=DBGVIEW(*ALL) INCDIR('.') OUTPUT(*PRINT)
CPPLEFLAGS=DBGVIEW(*ALL) INCDIR('.') OUTPUT(*PRINT)

TARGETS=runmic mic crt-inx fill-inx inxat loadinx

all: $(TARGETS)
	@echo "compilation done -- mic"

mic.module: stmt.hpp builtin.hpp

mic-main.module: mic-main.cpp
	system "crtcppmod $(BIN_LIB)/$* srcstmf('$<') $(CPPLEFLAGS)"
	ln -fs "/qsys.lib/$(BIN_LIB).lib/$*.module" $*.module

crt-inx: crt-inx.cpp
	system "crtbndcpp $(BIN_LIB)/$@ srcstmf('$<') dbgview(*all) $(CPPLEFLAGS)"
	ln -fs /qsys.lib/$(BIN_LIB).lib/$@.pgm $@

fill-inx: fill-inx.cpp
	system "crtbndcpp $(BIN_LIB)/$@ srcstmf('$<') $(CPPLEFLAGS)"
	ln -fs /qsys.lib/$(BIN_LIB).lib/$@.pgm $@

mic: mic.module mic-main.module
	$(CXX) -o $@ $^

clean:
	$(RM) $(TARGETS)

cmd_pnlgrp:
	@echo "attention: compiling CL command and panel-groups ..."
	system "CRTPNLGRP PNLGRP($(BIN_LIB)/MICHLP) SRCFILE(LS2008/DEC) SRCMBR(*PNLGRP)"
	system "CRTCMD CMD($(BIN_LIB)/MIC) PGM($(BIN_LIB)/MIC) SRCFILE(LS2008/DEC) SRCMBR(MIC) HLPPNLGRP($(BIN_LIB)/MICHLP) HLPID('HLP/MIC')"
