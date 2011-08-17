# This file is part of i5/OS Programmer's Toolkit.
# 
# Copyright (C) 2010, 2011  Junlei Li.
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
# makefile of subproject MI Portal
#

MIFLAGS=INCDIR('.' '../ref' '/usr/local/include/emi-inc/mi' '/usr/local/include/emi-inc/api')
RPGLEFLAGS=dbgview(*all) replace(*yes) incdir('/usr/local/include/rpg' '.')
CLEFLAGS=output(*print) dbgview(*all)
JAVAFLAGS=-g

BIN_LIB=
MAKERULES=rules.mk
TARGETS=uuid.class vrm.class prcnum enq007 enq.class deq.class

all: $(TARGETS)
	@echo "compilation done -- mi-portal/test"

miportal: miportal.module
	system "crtpgm pgm($(BIN_LIB)/$@) module($(BIN_LIB)/$@) actgrp(MIPORTAL)"
	ln -fs /qsys.lib/$(BIN_LIB).lib/$@.pgm $@

clean:
	rmflnk $(TARGETS)
