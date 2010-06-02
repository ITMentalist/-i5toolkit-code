# This file is part of i5/OS Programmer's Toolkit.
# 
# Copyright (C) 2010  Junlei Li (李君磊).
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

BIN_LIB=
MAKERULES=rules.mk
RPGFLAGS=dbgview(*all) replace(*yes) incdir('/usr/local/include/rpg')

TARGETS=t001 t002 t003 t004 t005 t006 t007 t008 t009 t010 t011 t012 t013 t014 t015 \
	t016 t017 t018 t019 t020 t021 t022 t023 t024 t025 \
	t028 t029 t030 t031 t032 t033 t034 t035 t036 t037 t038 t039 t040 t040a \
	t041 t042 t044 t045 t046 t049 t050 t051 t052 t053 t054 t055 t056 t057 \
	t059 t060 t061 t063 t064 t065 t066 t067 t068 t069 t070 t071 t072 t073 \
	t074 t075 t076

all: $(TARGETS)
	@echo "compilation done -- rpg"

clean:
	qsh -c "/usr/bin/rmflnk $(TARGETS)"
