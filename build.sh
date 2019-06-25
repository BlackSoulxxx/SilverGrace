#!/bin/bash
#
# Thanks to Tkkg1994 and djb77 for the script
#
# SilverGrace Build Script v1.2
#

# SETUP
# -----
export ARCH=arm64
export SUBARCH=arm64
export BUILD_CROSS_COMPILE=
export CROSS_COMPILE=$BUILD_CROSS_COMPILE
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`

export ANDROID_MAJOR_VERSION=p
export PLATFORM_VERSION=9.0.0

RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
DTBDIR=$OUTDIR/dtb
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include
PAGE_SIZE=2048
DTB_PADDING=0

DEFCONFIG=silvergrace_defconfig

export K_VERSION="v0.1"
export K_BASE="F"
export K_NAME="SilverGrace"
export REVISION="RC"
export KBUILD_BUILD_VERSION="1"
export KERNEL_VERSION="$K_NAME-$K_BASE-P-$K_VERSION"


# FUNCTIONS
# ---------
FUNC_DELETE_PLACEHOLDERS()
{
	find . -name \.placeholder -type f -delete
        echo "Placeholders Deleted from Ramdisk"
        echo ""
}

FUNC_CLEAN_DTB()
{
	if ! [ -d $DTSDIR ] ; then
		echo "no directory : "$DTSDIR""
	else
		echo "rm files in : "$RDIR/arch/$ARCH/boot/dts/*.dtb""
		rm $DTSDIR/*.dtb 2>/dev/null
		rm $DTBDIR/*.dtb 2>/dev/null
		rm $OUTDIR/boot.img-dtb 2>/dev/null
		rm $OUTDIR/boot.img-zImage 2>/dev/null
	fi
}

FUNC_BUILD_KERNEL()
{
	echo ""
        echo "Model: $MODEL"
        echo "build common config="$DEFCONFIG""

	cp -f $RDIR/arch/$ARCH/configs/$DEFCONFIG $RDIR/arch/$ARCH/configs/tmp_defconfig
	
	#FUNC_CLEAN_DTB

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			tmp_defconfig || exit -1
	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
	echo ""

	rm -f $RDIR/arch/$ARCH/configs/tmp_defconfig
}

FUNC_BUILD_DTB()
{
	[ -f "$DTCTOOL" ] || {
		echo "You need to run ./build.sh first!"
		exit 1
	}
	case $MODEL in
	N935F)
		DTSFILES="	exynos8890-gracelte_eur_open_00 exynos8890-gracelte_eur_open_01
				exynos8890-gracelte_eur_open_02 exynos8890-gracelte_eur_open_03
				exynos8890-gracelte_eur_open_05 exynos8890-gracelte_eur_open_07
				exynos8890-gracelte_eur_open_09 exynos8890-gracelte_eur_open_11"
		;;
	*)

		echo "Unknown device: $MODEL"
		exit 1
		;;
	esac
	mkdir -p $OUTDIR $DTBDIR
	cd $DTBDIR || {
		echo "Unable to cd to $DTBDIR!"
		exit 1
	}
	rm -f ./*
	echo "Processing dts files."
	for dts in $DTSFILES; do
		echo "=> Processing: ${dts}.dts"
		${CROSS_COMPILE}cpp -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "${dts}.dts"
		echo "=> Generating: ${dts}.dtb"
		$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
	done
	echo "Generating dtb.img."
	$RDIR/scripts/dtbtool_exynos/dtbtool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE
	echo "Done."
}

FUNC_BUILD_RAMDISK()
{
	echo ""
	echo "Building Ramdisk"

		
	cd $RDIR/build
	mkdir temp 2>/dev/null
	cp -rf aik/. temp
	cp -rf ramdisk/. temp
	rm -f temp/split_img/boot.img-zImage
	rm -f temp/split_img/boot.img-dtb
	mv $RDIR/arch/$ARCH/boot/Image temp/split_img/boot.img-zImage
	mv $RDIR/arch/$ARCH/boot/dtb.img temp/split_img/boot.img-dtb
	cd temp
	
	echo "Model: $MODEL"

	./repackimg.sh

	echo SEANDROIDENFORCE >> image-new.img
	mkdir $RDIR/build/kernel-temp 2>/dev/null
	mv image-new.img $RDIR/build/kernel-temp/$MODEL-boot.img
	rm -rf $RDIR/build/temp

}

FUNC_BUILD_FLASHABLES()
{
	cd $RDIR/build
	mkdir temp
	cp -rf zip/common/. temp
	
	cd $RDIR/build/kernel-temp
	echo ""
	echo "Compressing kernels..."
	tar cv * | xz -9 > ../temp/silver/kernel.tar.xz

	cd $RDIR/build/temp
	zip -9 -r ../$ZIP_NAME *

	cd ..
	rm -rf temp kernel-temp ramdisk-temp
}



# MAIN PROGRAM
# ------------

MAIN()
{

(
	START_TIME=`date +%s`
	FUNC_DELETE_PLACEHOLDERS
	FUNC_BUILD_KERNEL
	FUNC_BUILD_DTB
	FUNC_BUILD_RAMDISK
	if [ $ZIP == "yes" ]; then
	    FUNC_BUILD_FLASHABLES
	fi
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time is $ELAPSED_TIME seconds"
	echo ""
) 2>&1 | tee -a ./$MODEL-build.log

	echo "Your flasheable release can be found in the build folder"
	echo ""
}


# PROGRAM START
# -------------
clear
echo "***********************"
echo "SilverGrace Build Script"
echo "***********************"
echo ""
echo ""
echo "Build Kernel for:"
echo ""
echo "NoteFE One UI"
echo "(1) NoteFE N935F"
echo ""
echo ""
echo ""
read -p "Select an option to compile the kernel " prompt


if [ $prompt == "1" ]; then

    echo "NoteFE N935F Selected"

    MODEL=N935F
    ZIP=yes
    ZIP_NAME=$K_NAME-$MODEL-F-$K_VERSION.zip
    MAIN
fi





