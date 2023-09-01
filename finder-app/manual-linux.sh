#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc) Image dtbs modules
#    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules_install INSTALL_MOD_PATH=${OUTDIR}/rootfs
#    cp arch/${ARCH}/boot/Image ${OUTDIR}/
     cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/

fi

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi
echo "#####################################"
# TODO: Create necessary base directories
mkdir -p ${OUTDIR}/rootfs/{dev,proc,sys,bin,sbin,etc/init.d,home/conf,lib,lib64,tmp,usr/bin,usr/lib,usr/sbin,var/log}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
else
    cd busybox
fi

# TODO: Make and install busybox
 make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc) all
 make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc) install
 
# chmod +s ${OUTDIR}/busybox 
cd ${OUTDIR}/busybox/_install/
echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
cp ${OUTDIR}/linux-stable/arch/${ARCH}/lib/*  ${OUTDIR}/rootfs/lib64
#cp /home/linux/arm/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib
cp /home/linux/arm/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/ld-2.31.so ${OUTDIR}/rootfs/lib/ld-linux-aarch64.so.1
#cp /home/linux/arm/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64
cp /home/linux/arm/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libm-2.31.so ${OUTDIR}/rootfs/lib64/libm.so.6
#cp /home/linux/arm/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64
cp /home/linux/arm/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libresolv-2.31.so* ${OUTDIR}/rootfs/lib64/libresolv.so.2
#cp /home/linux/arm/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64
cp /home/linux/arm/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libc-2.31.so* ${OUTDIR}/rootfs/lib64/libc.so.6
# Copy the sh binary to the root filesystem
cp ${OUTDIR}/busybox/_install/bin/* ${OUTDIR}/rootfs/bin/
cp ${OUTDIR}/busybox/_install/bin/sh ${OUTDIR}/rootfs/bin/
cp ${OUTDIR}/busybox/_install/sbin/init ${OUTDIR}/rootfs/sbin/
# TODO: Make device nodes
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/console c 5 1
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/ram0 b 1 0
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/ttyS0 c 4 64
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/tty c 5 0
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/zero c 1 5
# TODO: Clean and build the writer utility
cd ${FINDER_APP_DIR}
make clean
make  ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
echo "________________"
cp ${FINDER_APP_DIR}/finder.sh ${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/writer ${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/conf/username.txt ${OUTDIR}/rootfs/home/conf
cp ${FINDER_APP_DIR}/finder-test.sh ${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/autorun-qemu.sh ${OUTDIR}/rootfs/home
# TODO: Chown the root directory
sudo chown -R root:root ${OUTDIR}/rootfs
# TODO: Create initramfs.cpio.gz
cd ${OUTDIR}/rootfs
find . | cpio -H newc -ov --owner root:root  > ${OUTDIR}/initramfs.cpio
gzip -9 ${OUTDIR}/initramfs.cpio
echo "______________DONE_______________"
