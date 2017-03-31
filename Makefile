ASRC=./src/asm
DSRC=./src/d
LS=./ls
VPATH = $(ASRC):$(DSRC):$(LS)

OSNAME=os
BIN=./bin
IMG=$(BIN)/$(OSNAME).img
OSSYS=$(BIN)/$(OSNAME).sys
IPL=$(BIN)/ipl.bin

DC=ldc2 -m32 -relocation-model=static
# DC=dmd -m32 -betterC

LD=ld -m elf_i386 --oformat binary
AS=as --32 -march=i386

QEMU=qemu-system-i386 -m 100 -localtime -vga std -fda
program := $(DSRC)/boot.d $(ASRC)/head.s $(ASRC)/func.s $(ASRC)/ipl.s


$(IMG) : $(OSSYS) $(IPL)
	mformat -f 1440 -C -B $(IPL) -i $(IMG) ::
	mcopy $(OSSYS) -i $(IMG) ::

$(BIN):
	mkdir -p $(BIN)

$(BIN)/%.bin: %.s %.ld $(BIN)
	$(CC) $< -nostdlib -T $(word 2, $^) -o $@

$(BIN)/%.os: %.s $(BIN)
	$(AS) $< -o $@

$(BIN)/%.od: %.d $(BIN)
	$(DC) -c $< -of=$@

$(OSSYS) : $(BIN)/head.bin $(BIN)/func.os $(BIN)/boot.od
	$(LD) -o $(BIN)/boot.bin -e Main $(BIN)/*.od $(BIN)/*.os
	cat $(BIN)/head.bin $(BIN)/boot.bin > $(OSSYS)


.PHONY: run debug clean

run: $(IMG)
	$(QEMU) $(IMG)

debug: $(IMG)
	$(QEMU) -s -S $(IMG) -redir tcp:5555:127.0.0.1:1234 &

clean:
	rm -vrf $(BIN)/*
