#!/bin/bash
#
# Thanks to djb77 
#
# SilverGrace Cleaning Script 1.0
#

# Clean Build Data
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
make mrproper -j$BUILD_JOB_NUMBER
make ARCH=arm64 distclean -j$BUILD_JOB_NUMBER

rm -f ./*.log


# Remove Release files
rm -f $PWD/build/*.zip 2>/dev/null
rm -rf $PWD/build/temp 2>/dev/null
rm -rf $PWD/build/kernel-temp 2>/dev/null
rm -f $PWD/arch/arm64/configs/tmp_defconfig 2>/dev/null
rm -f $PWD/build/zip/common/silver/kernel.tar.xz 2>/dev/null
rm -rf $PWD/net/wireguard 2>/dev/null
rm -r $PWD/arch/arm64/boot/dts/*.dtb 2>/dev/null
rm -f $PWD/.wireguard-fetch-lock 2>/dev/null


# Removed Created dtb Folder
rm -rf $PWD/arch/arm64/boot/dtb 2>/dev/null


# Recreate Ramdisk Placeholders
echo "" > build/ramdisk/ramdisk/acct/.placeholder
echo "" > build/ramdisk/ramdisk/cache/.placeholder
echo "" > build/ramdisk/ramdisk/config/.placeholder
echo "" > build/ramdisk/ramdisk/data/.placeholder
echo "" > build/ramdisk/ramdisk/dev/.placeholder
echo "" > build/ramdisk/ramdisk/keydata/.placeholder
echo "" > build/ramdisk/ramdisk/keyrefuge/.placeholder
echo "" > build/ramdisk/ramdisk/lib/modules/.placeholder
echo "" > build/ramdisk/ramdisk/mnt/.placeholder
echo "" > build/ramdisk/ramdisk/omr/.placeholder
echo "" > build/ramdisk/ramdisk/proc/.placeholder
echo "" > build/ramdisk/ramdisk/storage/.placeholder
echo "" > build/ramdisk/ramdisk/sys/.placeholder
echo "" > build/ramdisk/ramdisk/system/.placeholder



