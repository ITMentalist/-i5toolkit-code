# mmmmm

%.swf : %.as
	$(MXMLC) $(MXFLAGS) $<
%.class : %.java
	javac -g $<

MXMLC=mxmlc
MXFLAGS=-compiler.debug
CFLAGS=-g

INCDIR=as400/prototype
TARGETS=misc.swf test.swf test2.swf t003.swf t004.swf pixels.class t005.swf \
	t006.swf t007.swf t008.swf

all: $(TARGETS)
	@echo "......"

t008.swf : Button1.as

$(TARGETS) : $(INCDIR)/*.as

t005.swf: $(INCDIR)/*.as

t003.swf: $(INCDIR)/*.as

test2.swf: test2.as $(INCDIR)/DES.as $(INCDIR)/RemoteCommand.as $(INCDIR)/AS400.as $(INCDIR)/ENC.as UButton.as

test.swf: test.as $(INCDIR)/DES.as $(INCDIR)/RemoteCommand.as $(INCDIR)/AS400.as $(INCDIR)/ENC.as

misc.swf: misc.as $(INCDIR)/DES.as $(INCDIR)/ENC.as $(INCDIR)/Conv37.as

test: test.o des.o
	$(CC) -o $@ $^

clean:
	rm $(TARGETS)
