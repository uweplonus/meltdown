SHELL = /bin/sh
.SUFFIXES: .asm
NASM = /usr/bin/nasm
NASM_OPTS = -f elf64 -g -F stabs
LD = /usr/bin/ld
LD_OPTS = -melf_x86_64

clean:
	rm -rf bin
	rm -rf build

all: prepare cpuinfo sighandler

prepare:
	mkdir -p bin
	mkdir -p build

print.o:
	$(NASM) $(NASM_OPTS) src/print.asm -l build/print.lst -o build/print.o

cpuinfo.o:
	$(NASM) $(NASM_OPTS) src/cpuinfo.asm -l build/cpuinfo.lst -o build/cpuinfo.o

sighandler.o:
	$(NASM) $(NASM_OPTS) src/sighandler.asm -l build/sighandler.lst -o build/sighandler.o

cpuinfo: print.o cpuinfo.o
	$(LD) $(LD_OPTS) -o bin/cpuinfo build/print.o build/cpuinfo.o

sighandler: print.o sighandler.o
	$(LD) $(LD_OPTS) -o bin/sighandler build/print.o build/sighandler.o
