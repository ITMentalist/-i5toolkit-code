# This file is part of i5/OS Programmer's Toolkit.
# 
# Copyright (C) 2009, 2011  Junlei Li (李君磊).
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
# makefile of emi-inc/test
#

BIN_LIB=lsbin

MIFLAGS=incdir('/usr/local/include/emi-inc/mi' '/usr/local/include/emi-inc/api')
TARGETS=e001 e002 e003 e004 e005

all: $(TARGETS)
	@echo "end of compilation: sub-dir emi-inc/test."

clean:
	rmflnk $(TARGETS)
