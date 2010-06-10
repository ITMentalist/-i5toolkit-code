# 

.SUFFIXES: .rpg .rpgle .c .cpp .clp .clle .cmd .cl-cmd .module .pf .lf .file \
	.mi .emi .uim .pnlgrp

#PRESET VARIABLES
MAKE=make

#SINGLE SUFFIX RULES
.c:
	system "crtbndc $(BIN_LIB)/$@ srcstmf('$<') dbgview(*all) output(*print)"
	ln -fs /qsys.lib/$(BIN_LIB).lib/$@.pgm $@
.cpp:
	system "crtbndcpp $(BIN_LIB)/$@ srcstmf('$<') dbgview(*all) output(*print)"
	ln -fs /qsys.lib/$(BIN_LIB).lib/$@.pgm $@
.mi:
	system "i5toolkit/mic $(BIN_LIB)/$@ srcpath($<) option(*replace *list *xref *atr)"
	ln -fs /qsys.lib/$(BIN_LIB).lib/$@.pgm $@
.emi:
	system "i5toolkit/mic $(BIN_LIB)/$@ srcpath($<) option(*replace *list *xref *atr)"
	ln -fs /qsys.lib/$(BIN_LIB).lib/$@.pgm $@
.rpgle:
	system "crtbndrpg $(BIN_LIB)/$@ srcstmf('$<') $(RPGLEFLAGS)"
	ln -fs "/qsys.lib/$(BIN_LIB).lib/$@.pgm" $@
.clp:
	system "i5toolkit/crtfrmstmf obj($(BIN_LIB)/$@) cmd(CRTCLPGM) srcstmf('$<') parm('$(CLFLAGS)')"
	ln -fs "/qsys.lib/$(BIN_LIB).lib/$@.pgm" $@
.clle:
	system "i5toolkit/crtfrmstmf obj($(BIN_LIB)/$@) cmd(CRTBNDCL) srcstmf('$<') parm('$(CLLEFLAGS)')"
	ln -fs "/qsys.lib/$(BIN_LIB).lib/$@.pgm" $@
.cl-cmd.cmd:
	system "i5toolkit/crtfrmstmf obj($(BIN_LIB)/$*) cmd(CRTCMD) srcstmf('$<') parm('PGM($(BIN_LIB)/$*) $(CMDFLAGS)')"
	ln -fs "/qsys.lib/$(BIN_LIB).lib/$*.cmd" $*.cmd
.rpg:
	system "i5toolkit/crtfrmstmf obj($(BIN_LIB)/$@) cmd(CRTRPGPGM) srcstmf('$<') parm('$(RPGFLAGS)')"
	ln -fs "/qsys.lib/$(BIN_LIB).lib/$@.pgm" $@
.rpgle.module:
	system "crtrpgmod $(BIN_LIB)/$* srcstmf('$<') $(RPGLEFLAGS)"
	ln -fs "/qsys.lib/$(BIN_LIB).lib/$*.module" $*.module
.clle.module:
	system "i5toolkit/crtfrmstmf obj($(BIN_LIB)/$*) cmd(CRTCLMOD) srcstmf('$<') parm('$(CLLEFLAGS)')"
	ln -fs "/qsys.lib/$(BIN_LIB).lib/$*.module" $*.module
.pf.file:
	system "i5toolkit/crtfrmstmf obj($(BIN_LIB)/$*) cmd(CHGPF) srcstmf('$<') parm('$(CHGPFFLAGS)')"
	ln -fs "/qsys.lib/$(BIN_LIB).lib/$*.file" $*.file
.lf.file:
	-system "dltf file($(BIN_LIB)/$*)"
	system "i5toolkit/crtfrmstmf obj($(BIN_LIB)/$*) cmd(CRTLF) srcstmf('$<') parm('$(CRTLFFLAGS)')"
	ln -fs "/qsys.lib/$(BIN_LIB).lib/$*.file" $*.file
.uim.pnlgrp:
	system "i5toolkit/crtfrmstmf obj($(BIN_LIB)/$*) cmd(CRTPNLGRP) srcstmf('$<') parm('$(CRTPNLGRPFLAGS)')"
	ln -fs "/qsys.lib/$(BIN_LIB).lib/$*.pnlgrp" $*.pnlgrp
