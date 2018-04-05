#!/bin/sh
DISK_IMG=disk_images/test.img

# This script assembles the CTOAGNOS bootloader, kernel and programs
# with NASM & GCC, and then creates floppy and CD images (on Linux)

# Only the root user can mount the floppy disk image as a virtual
# drive (loopback mounting), in order to copy across the files

if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi

rm -rf bin
mkdir bin

if [ ! -d "disk_images" ]; then
	mkdir disk_images
fi

rm -f $DISK_IMG
echo ">>> Creating new floppy image..."
mkdosfs -C $DISK_IMG 1440 || exit


echo ">>> Assembling bootloader..."

nasm -O0 -w+orphan-labels -f bin -o bin/bootloader.bin source/bootloader.asm || exit

echo ">>> Assembling bootstrapper..."

cd source

nasm -O0 -w+orphan-labels -f bin -o ../bin/boot.bin boot.asm || exit


echo ">>> Compiling kernel..."

#gcc -O0 -m32 -masm=intel -march=i386 -nostdlib -fno-builtin -ffreestanding -fno-exceptions -fno-rtti -S kernel.s test.cpp test2.cpp || exit
#gcc -O0 -m32 -masm=intel -march=i386 -nostdlib -fno-builtin -ffreestanding -fno-exceptions -fno-rtti -c kernel.s test.cpp test2.cpp || exit

gcc -O0 -g -m32 -masm=intel -march=i386 -nostdlib -fno-builtin -ffreestanding -fno-exceptions -fno-rtti -Wl,--nmagic,--script=../linker.ld -o ../bin/kernel.bin kernel.s test.cpp test2.cpp || exit

cd ..

echo ">>> Compile done!"


echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=bin/bootloader.bin of=$DISK_IMG || exit


echo ">>> Copying kernel and programs..."

rm -rf tmp-loop

mcopy -i $DISK_IMG bin/kernel.bin ::kernel.bin
mcopy -i $DISK_IMG bin/boot.bin ::boot.bin

sleep 0.2

echo '>>> Done!'