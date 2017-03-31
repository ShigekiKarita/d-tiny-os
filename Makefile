ASRC=./src/asm
DSRC=./src/d
BIN=./bin
LS=./ls

OSNAME=os
IMG=$(BIN)/$(OSNAME).img
OSSYS=$(BIN)/$(OSNAME).sys
IPL=$(BIN)/ipl.bin

DC=ldc2
DOPT=-m32 -relocation-model=static

LD=ld -m elf_i386 --oformat binary
AS=as --32 -march=i386

QEMU=qemu-system-i386 -m 100 -localtime -vga std -fda
program := $(DSRC)/boot.d $(ASRC)/head.s $(ASRC)/func.s $(ASRC)/ipl.s

$(IMG) : $(OSSYS) $(IPL)
	mformat -f 1440 -C -B $(IPL) -i $(IMG) ::
	mcopy $(OSSYS) -i $(IMG) ::

$(BIN)/boot.o: $(DSRC)/boot.d
	$(DC) $(DOPT) -c $(DSRC)/*.d -of=$(BIN)/boot.o

$(BIN)/head.bin: $(ASRC)/head.s
	$(CC) $(ASRC)/head.s -nostdlib -T$(LS)/head.ld -o $(BIN)/head.bin

$(BIN)/func.o: $(ASRC)/func.s
	$(AS) $(ASRC)/func.s -o $(BIN)/func.o

$(OSSYS) : $(BIN)/head.bin $(BIN)/func.o $(BIN)/boot.o
	$(LD) -o $(BIN)/boot.bin -e Main $(BIN)/boot.o $(BIN)/func.o
	cat $(BIN)/head.bin $(BIN)/boot.bin > $(OSSYS)

$(IPL) : $(ASRC)/ipl.s
	$(CC) $(GCCOPT) $(ASRC)/ipl.s -nostdlib -T$(LS)/ipl.ld -o $(IPL)


.PHONY: run debug clean

run: $(IMG)
	$(QEMU) $(IMG)

debug: $(IMG)
	$(QEMU) -s -S $(IMG) -redir tcp:5555:127.0.0.1:1234 &

clean:
	rm -vrf $(BIN)/*
