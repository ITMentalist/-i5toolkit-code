# 

.SUFFIXES: .c .cpp \
	.mi .emi

#PRESET VARIABLES
MAKE=make

#SINGLE SUFFIX RULES
.c:
	system "crtbndc $(BIN_LIB)/$@ srcstmf('$<') dbgview(*all) output(*print)"
	ln -fs /qsys.lib/$(BIN_LIB).lib/$@.pgm $@
.mi:
	system "i5toolkit/mic $(BIN_LIB)/$@ srcpath($<) option(*replace *list *xref *atr)"
	ln -fs /qsys.lib/$(BIN_LIB).lib/$@.pgm $@
.emi:
	system "i5toolkit/mic $(BIN_LIB)/$@ srcpath($<) option(*replace *list *xref *atr)"
	ln -fs /qsys.lib/$(BIN_LIB).lib/$@.pgm $@
