# Reserected by WindowsXP95
# A special thanks goes to jam7 for making the original script
# BRANCH name is taken from https://chromium.googlesource.com/chromiumos/manifest/+refs
# The information of release is taken from https://chromereleases.googleblog.com/search/label/Stable%20updates
#A list of the current branch names can be found in the releases.txt file
TARGET = chromiumos
BRANCH = release-R84-13099.B

# Boards Selection. More will be added
BOARD_ARM32 = arm-generic
BOARD_ARM64= arm64-generic
BOARD_X86 = x86-generic
BOARD_X64 = amd64-generic

# This can be changed to the amount of cores. The default is 4.
NPROC = 4

export PATH := ${PWD}/depot_tools:${PATH}


all: setup images

setup: depot_tools ${TARGET}
	cd depot_tools; git pull origin --rebase
	cd ${TARGET}; repo sync -j${NPROC}
	-cd ${TARGET}/src; patch -p3 --forward < ${PWD}/update_bootloaders.sh.patch

depot_tools:
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

${TARGET}: FORCE
	mkdir -p ${TARGET}
	cd ${TARGET}; repo init -u https://chromium.googlesource.com/chromiumos/manifest.git --repo-url https://chromium.googlesource.com/external/repo.git -b ${BRANCH}

# build packages without debug symbol and with NDEBUG macro
# build images with "chronos" password for "chronos" user
# images are placed under ${TARGET}/src/build/images/

images: arm32 arm64  x86 x64

arm32:
	cd ${TARGET}; cros_sdk -- setup_board --board=${BOARD_ARM32}
	cd ${TARGET}; cros_sdk -- ./set_shared_user_password.sh chronos
	cd ${TARGET}; cros_sdk -- ./build_packages --board=${BOARD_ARM32} --nowithdebug
	cd ${TARGET}; cros_sdk -- ./build_image --board=${BOARD_ARM32} --noenable_rootfs_verification dev
	
arm64:
	cd ${TARGET}; cros_sdk -- setup_board --board=${BOARD_ARM64}
	cd ${TARGET}; cros_sdk -- ./set_shared_user_password.sh chronos
	cd ${TARGET}; cros_sdk -- ./build_packages --board=${BOARD_ARM64} --nowithdebug
	cd ${TARGET}; cros_sdk -- ./build_image --board=${BOARD_ARM64} --noenable_rootfs_verification dev


x86:
	cd ${TARGET}; cros_sdk -- setup_board --board=${BOARD_X86}
	cd ${TARGET}; cros_sdk -- ./set_shared_user_password.sh chronos
	cd ${TARGET}; cros_sdk -- ./build_packages --board=${BOARD_X86} --nowithdebug
	cd ${TARGET}; cros_sdk -- ./build_image --board=${BOARD_X86} --noenable_rootfs_verification dev

x64:
	cd ${TARGET}; cros_sdk -- setup_board --board=${BOARD_X64}
	cd ${TARGET}; cros_sdk -- ./set_shared_user_password.sh chronos
	cd ${TARGET}; cros_sdk -- ./build_packages --board=${BOARD_X64} --nowithdebug
	cd ${TARGET}; cros_sdk -- ./build_image --board=${BOARD_X64} --noenable_rootfs_verification dev

kvm: armk x86k x64k
armk:
	cd ${TARGET}; cros_sdk -- ./image_to_vm.sh --board=${BOARD_ARM}

x86k:
	cd ${TARGET}; cros_sdk -- ./image_to_vm.sh --board=${BOARD_X86}

x64k:
	cd ${TARGET}; cros_sdk -- ./image_to_vm.sh --board=${BOARD_X64}

.SECONDEXPANSION:
dist: armd x86d x64d armdk x86dk x64dk
distq: armdq x86dq x64dq

armd:
	cp ${TARGET}/src/build/images/${BOARD_ARM}/latest/chromiumos_image.bin dist/chromiumos_image-$(basename $(shell readlink ${TARGET}/src/build/images/${BOARD_ARM}/latest))-${BOARD_ARM}.bin

x86d:
	cp ${TARGET}/src/build/images/${BOARD_X86}/latest/chromiumos_image.bin dist/chromiumos_image-$(basename $(shell readlink ${TARGET}/src/build/images/${BOARD_X86}/latest))-${BOARD_X86}.bin

x64d:
	cp ${TARGET}/src/build/images/${BOARD_X64}/latest/chromiumos_image.bin dist/chromiumos_image-$(basename $(shell readlink ${TARGET}/src/build/images/${BOARD_X64}/latest))-${BOARD_X64}.bin

armdk:
	cp ${TARGET}/src/build/images/${BOARD_ARM}/latest/chromiumos_qemu_image.bin dist/chromiumos_qemu_image-$(basename $(shell readlink ${TARGET}/src/build/images/${BOARD_ARM}/latest))-${BOARD_ARM}.bin

x86dk:
	cp ${TARGET}/src/build/images/${BOARD_X86}/latest/chromiumos_qemu_image.bin dist/chromiumos_qemu_image-$(basename $(shell readlink ${TARGET}/src/build/images/${BOARD_X86}/latest))-${BOARD_X86}.bin

x64dk:
	cp ${TARGET}/src/build/images/${BOARD_X64}/latest/chromiumos_qemu_image.bin dist/chromiumos_qemu_image-$(basename $(shell readlink ${TARGET}/src/build/images/${BOARD_X64}/latest))-${BOARD_X64}.bin

armdq:
	qemu-img convert -f raw -O qcow2  ${TARGET}/src/build/images/${BOARD_ARM}/latest/chromiumos_qemu_image.bin dist/chromiumos_qemu_image-$(basename $(shell readlink ${TARGET}/src/build/images/${BOARD_ARM}/latest))-${BOARD_ARM}.qcow2

x86dq:
	qemu-img convert -f raw -O qcow2  ${TARGET}/src/build/images/${BOARD_X86}/latest/chromiumos_qemu_image.bin dist/chromiumos_qemu_image-$(basename $(shell readlink ${TARGET}/src/build/images/${BOARD_X86}/latest))-${BOARD_X86}.qcow2

x64dq:
	qemu-img convert -f raw -O qcow2  ${TARGET}/src/build/images/${BOARD_X64}/latest/chromiumos_qemu_image.bin dist/chromiumos_qemu_image-$(basename $(shell readlink ${TARGET}/src/build/images/${BOARD_X64}/latest))-${BOARD_X64}.qcow2

FORCE:
