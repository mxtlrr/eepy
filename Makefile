AS 			 := nasm
ASFLAGS  := -felf32 -g

all: build
.PHONY: all

build: src/eepy.asm
	@mkdir -pv bin obj
	$(AS) $^ $(ASFLAGS) -o obj/eepy.o
	ld -melf_i386 obj/eepy.o -o bin/eepy