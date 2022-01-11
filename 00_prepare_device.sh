#!/bin/sh
source ./config

fdisk -l

echo -ne "
Is ${DEVICE} the drive you want to put Arch ARM on (y|n)?
"
read correct

case $correct in
    y|Y|yes|Yes|YES)
    ;;
    *) echo "Please adjust config file to specify the desired drive."; exit 1;;
esac

echo "formatting the drive"
dd if=/dev/zero of=$DEVICE bs=1M count=8

echo "o
n
p
1
2048
+256M
t
c
n
p
2


w" | fdisk $DEVICE

mkfs.vfat ${DEVICE}1
mkdir -p boot
mount ${DEVICE}1 boot

mkfs.ext4 ${DEVICE}2
mkdir -p root
mount ${DEVICE}2 root

bsdtar -xpf ArchLinuxARM-odroid-n2-latest.tar.gz -C root
mv root/boot/* boot

dd if=boot/u-boot.bin of=$DEVICE conv=fsync,notrunc bs=512 seek=1

sed -i 's%/dev/mmcblk1p1%/dev/mmcblk0p1%g' root/etc/fstab

cp 01_init_system.sh root/home/alarm/01_init_system.sh

umount root boot