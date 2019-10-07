#
# basic makefile for D language
#
#----------------------------------------------------------------------
#
DCC = dmd
DFLAGS = -w -I../include
SRC = $(wildcard *.d)
OBJ = $(SRC:.d=.o)
OUT = $(shell basename `pwd`)

arg1=-L../lib
arg2=-lTimerMessage

#- Not a typographic error -- the first '-L' tells DMD to pass the rest to the linker.
LIBS =-L$(arg1) -L$(arg2)

.PHONY: all debug release profile clean

all: debug

debug:   DFLAGS += -g -debug
release: DFLAGS += -O -release -version=release -inline -noboundscheck -X
profile: DFLAGS += -g -O -profile

debug release profile: $(OUT)

$(OUT): $(OBJ)
	$(DCC) $(DFLAGS) -of$@ $(OBJ) $(LIBS)

%.o: %.d
	$(DCC) $(DFLAGS) -c $<

clean:
	rm -f *~ *.json $(OBJ) $(OUT) trace.{def,log}

#
#- END>> basic makefile for D language
#
