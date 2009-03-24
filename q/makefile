#

MAKER=LSBIN/RGMAKE
HOST=i810
RP=/home/ljl/chqs/i5tool/q
HOSTCMD=rexec $(HOST)
BINLIB=I5TOOLKIT

all: upload compile
	echo "end of compilation :o:"

upload:
	ls *mi qmakefile | env WN_REMOTE_PATH=$(RP) WN_HOST=$(HOST) wn

compile:
	$(HOSTCMD) "CALL PGM($(MAKER)) PARM(X'00037F' '$(BINLIB)' '$(RP)' '')"

clean:
	$(HOSTCMD) "CALL PGM($(MAKER)) PARM(X'00037F' '$(BINLIB)' '$(RP)' 'clean')"

