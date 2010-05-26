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
# makefile of q tools
#
# to make program object, type: make
# to make panel groups and CL commands, type: make uim_cmd
# to 
#

MAKER=LSBIN/RUNSH
HOST=g525
RP=/home/ljl/chqs/q
HOSTCMD=rexec $(HOST)
BINLIB=I5TOOLKIT

all: check-source upload compile
	echo "end of compilation :o:"

check-source:
	bash check-tab.sh *.mi

upload:
	ls *mi qmakefile | env WN_REMOTE_PATH=$(RP) WN_HOST=$(HOST) wn

compile:
	$(HOSTCMD) "CALL PGM($(MAKER)) PARM('00037' 'cd $(RP); export OS400=yes OUTPUTDIR=$(BINLIB); gmake -fqmakefile')"

clean:
	$(HOSTCMD) "CALL PGM($(MAKER)) PARM('00037' 'cd $(RP); export OS400=yes OUTPUTDIR=$(BINLIB); gmake -fqmakefile clean')"

uim_cmd:
	$(HOSTCMD) "CRTPNLGRP PNLGRP(I5TOOLKIT/DSPQATHLP) SRCFILE(LS2008/DEC) SRCMBR(*PNLGRP) INCFILE(*SRCFILE) REPLACE(*YES)"
	$(HOSTCMD) "CRTPNLGRP PNLGRP(I5TOOLKIT/DSPQAT) SRCFILE(LS2008/DEC) SRCMBR(*PNLGRP) INCFILE(*SRCFILE) REPLACE(*YES)"
	$(HOSTCMD) "CRTPNLGRP PNLGRP(I5TOOLKIT/DSPQM) SRCFILE(LS2008/DEC) SRCMBR(*PNLGRP) INCFILE(*SRCFILE) REPLACE(*YES)"
	$(HOSTCMD) "CRTCMD CMD(I5TOOLKIT/DSPQD) PGM(I5TOOLKIT/QATTR) SRCFILE(LS2008/DEC) SRCMBR(*CMD) MODE(*ALL) ALLOW(*ALL) HLPPNLGRP(I5TOOLKIT/DSPQATHLP) HLPID('HELP/ABT')"
	$(HOSTCMD) "CRTCMD CMD(I5TOOLKIT/DSPQMSG) PGM(I5TOOLKIT/QMSG) SRCFILE(LS2008/DEC) SRCMBR(*CMD) MODE(*ALL) ALLOW(*ALL) HLPPNLGRP(I5TOOLKIT/DSPQATHLP) HLPID('HELP/ABTQM')"
	$(HOSTCMD) "CRTCMD CMD(I5TOOLKIT/CLRUSRQ) PGM(I5TOOLKIT/CLRUSRQ) SRCFILE(LS2008/DEC) SRCMBR(*CMD) MODE(*ALL) ALLOW(*ALL) HLPPNLGRP(I5TOOLKIT/DSPQATHLP) HLPID('HLP/CLQ')"
	$(HOSTCMD) "CRTCMD CMD(I5TOOLKIT/ENQUSRQ) PGM(I5TOOLKIT/ENQUSRQ) SRCFILE(LS2008/DEC) SRCMBR(*CMD) MODE(*ALL) ALLOW(*ALL) HLPPNLGRP(I5TOOLKIT/DSPQATHLP) HLPID('HLP/ENQ')"

pkg:
	$(HOSTCMD) "STRQSH CMD('chown -R QDFTOWN /qsys.lib/i5toolkit.lib')"
	@echo "Now, save library $(BINLIB) and download it."
