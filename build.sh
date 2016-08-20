#!/bin/sh
DISK_IMG=disk_images/ctoagnos.img

# This script assembles the MikeOS bootloader, kernel and programs
# with NASM, and then creates floppy and CD images (on Linux)

# Only the root user can mount the floppy disk image as a virtual
# drive (loopback mounting), in order to copy across the files

# (If you need to blank the floppy image: 'mkdosfs disk_images/mikeos.flp')


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


echo ">>> Assembling MikeOS kernel..."

cd source
nasm -O0 -w+orphan-labels -f bin -o ../bin/kernel.bin kernel.asm || exit

echo ">>> Assembling programs..."

# cd programs

# for i in *.asm
# do
	# nasm -O0 -w+orphan-labels -f bin $i -o ../../bin/programs/$(basename $i .asm).bin || exit
# done

# cd ..
cd ..

echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=bin/bootloader.bin of=$DISK_IMG || exit


echo ">>> Copying MikeOS kernel and programs..."

rm -rf tmp-loop

mcopy -i $DISK_IMG bin/kernel.bin ::kernel.bin

# cd bin/programs
# for i in *.bin
# do
	# mcopy -i ../../$DISK_IMG $i ::$i
# done
# cd ../..

sleep 0.2

echo '>>> Done!'

