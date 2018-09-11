CC=gcc

# Level of optimisation
ifndef OPTLVL
OPTLVL=-O0
endif

ODIR=bin
OPDIR:=$(ODIR)/objs
SDIR=source
IMGS = disk_images
IMGNAME := $(IMGS)/ctoagnos.img

CFLAGS := $(OPTLVL) -g -m32 -masm=intel -march=i386 -std=c++11 -I$(SDIR)/.
CFLAGS += -nostdlib -fno-builtin -ffreestanding -mgeneral-regs-only -fno-exceptions -fno-rtti
LFLAGS = -Wl,--nmagic,--build-id=none,--script=linker.ld

# build each cpp in the source subdirectories
CPP = $(wildcard $(SDIR)/*/*.cpp)
# generate list of object files from cpp files
OBJ = $(CPP:%.cpp=$(OPDIR)/%.o)
# generate list of dependency files from object files
DEP = $(OBJ:%.o=%.d)

.DEFAULT_GOAL := ctoagnos

#disable command echoing by default
ifndef VERBOSE
.SILENT:
endif

.PHONY: ctoagnos
ctoagnos : $(IMGNAME)

$(ODIR)/bootloader.bin : $(SDIR)/bootloader.asm
	echo ">> Assembling bootloader..."
	nasm -O0 -w+orphan-labels -f bin -I $(SDIR)/ -o $@ $^

$(ODIR)/boot.bin : $(SDIR)/boot.asm
	echo ">> Assembling bootstrapper..."
	nasm -O0 -w+orphan-labels -f bin -I $(SDIR)/ -o $@ $^

-include $(DEP)

$(OPDIR)/%.o : %.cpp
	echo " Compiling $<"
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -MMD -c -o $@ $<

$(ODIR)/kernel.o : $(SDIR)/kernel.s $(SDIR)/kernel.cpp $(OBJ)
	echo ">> Compiling kernel..."
	$(CC) $(CFLAGS) $(LFLAGS) -o $@ $^

$(ODIR)/kernel.bin : $(ODIR)/kernel.o
	objcopy -O binary $^ $@

$(IMGNAME) : $(ODIR)/bootloader.bin $(ODIR)/boot.bin $(ODIR)/kernel.bin
	echo ">> Creating boot disk..."
	rm -f $(IMGNAME)
	mkdosfs -C $(IMGNAME) 1440
	dd status=noxfer conv=notrunc if=$(ODIR)/bootloader.bin of=$(IMGNAME)
	mcopy -i $(IMGNAME) $(ODIR)/boot.bin ::boot.bin
	mcopy -i $(IMGNAME) $(ODIR)/kernel.bin ::kernel.bin


.PHONY: clean
clean:
	echo ">> Cleaning..."
	rm -rf $(ODIR)
	mkdir $(ODIR)
	rm -f $(IMGNAME)
	mkdir -p $(IMGS)