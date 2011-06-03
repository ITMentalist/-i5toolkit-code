# mmmmm

%.swf : %.as
	$(MXMLC) $(MXFLAGS) $<

MXMLC=mxmlc
MXFLAGS=-compiler.debug
CFLAGS=-g

INCDIR=as400/prototype
TARGETS=misc.swf test.swf test2.swf

all: $(TARGETS)
	@echo "......"

test2.swf: test2.as $(INCDIR)/DES.as $(INCDIR)/RemoteCommand.as $(INCDIR)/AS400.as $(INCDIR)/ENC.as UButton.as

test.swf: test.as $(INCDIR)/DES.as $(INCDIR)/RemoteCommand.as $(INCDIR)/AS400.as $(INCDIR)/ENC.as

misc.swf: misc.as $(INCDIR)/DES.as $(INCDIR)/ENC.as $(INCDIR)/Conv37.as

test: test.o des.o
	$(CC) -o $@ $^

clean:
	rm $(TARGETS)
