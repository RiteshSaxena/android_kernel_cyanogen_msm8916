#
# Copyright © 2016, Varun Chitre "varun.chitre15" <varun.chitre15@gmail.com>
# Copyright © 2017, Ritesh Saxena <riteshsax007@gmail.com>
#
# Custom build script
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm64/boot/Image
DTBTOOL=$KERNEL_DIR/dtbToolCM
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
# Modify the following variable if you want to build
export CROSS_COMPILE=$KERNEL_DIR/../7.x/bin/aarch64-linaro-linux-android-
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Ritesh"
export KBUILD_BUILD_HOST="MonsterMachine"
export USE_CCACHE=1
BUILD_DIR=$KERNEL_DIR/build
VERSION="X8.1"
DATE=$(date -u +%Y%m%d-%H%M)

compile_kernel ()
{
echo -e "$blue***********************************************"
echo "             Compiling Reloaded kernel        "
echo -e "***********************************************$nocol"
rm -f $KERN_IMG
make lineageos_tomato_defconfig
make -j8
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/


make_zip
}

make_zip ()
{
echo "Making Zip"
rm -rf $BUILD_DIR/system
rm $BUILD_DIR/*.zip
rm $BUILD_DIR/tools/Image
rm $BUILD_DIR/tools/dt.img
mkdir $BUILD_DIR/system
mkdir $BUILD_DIR/system/lib
mkdir $BUILD_DIR/system/lib/modules
cp $KERNEL_DIR/drivers/staging/prima/wlan.ko $BUILD_DIR/system/lib/modules
cp $KERNEL_DIR/net/ipv4/tcp_bic.ko $BUILD_DIR/system/lib/modules
cp $KERNEL_DIR/net/ipv4/tcp_htcp.ko $BUILD_DIR/system/lib/modules
cp $KERNEL_DIR/arch/arm64/boot/Image $BUILD_DIR/tools
cp $KERNEL_DIR/arch/arm64/boot/dt.img $BUILD_DIR/tools
cd $BUILD_DIR
zip -r Reloaded™-$VERSION-$DATE.zip *
cd $KERNEL_DIR
}

case $1 in
clean)
make ARCH=arm64 -j8 clean mrproper
rm -rf $KERNEL_DIR/arch/arm/boot/dt.img
;;
dt)
make lineageos_tomato_defconfig
make dtbs -j8
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
;;
*)
compile_kernel
;;
esac
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
