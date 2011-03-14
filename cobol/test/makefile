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
# makefile of directory cobol/test
#

BIN_LIB=
MAKERULES=rules.mk
CBLLEFLAGS=dbgview(*all) replace(*yes) incdir('/usr/local/include/cobol' '.')
CBLFLAGS=genopt(*list *atr)
CLFLAGS=genopt(*list *xref)
MIFLAGS=incdir('.')

TARGETS=cbl001

all: $(TARGETS)
	@echo "compilation done -- cobol/test"

clean:
	qsh -c "/usr/bin/rmflnk $(TARGETS)"
