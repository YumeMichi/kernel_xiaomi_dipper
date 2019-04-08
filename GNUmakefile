# SPDX-License-Identifier: MIT
# Copyright (C) 2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.

MAKEFLAGS += --no-print-directory
ifeq ($(findstring -j,$(MAKEFLAGS)),)
MAKEFLAGS += -j$(shell nproc)
endif

default: all

TARGET_DEFCONFIG := dipper_defconfig

export ARCH=arm64
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

all:
	@printf "\e[1;32mGenerating configuration...\e[0m\n"
	@$(MAKE) -f Makefile O=out CC=clang $(TARGET_DEFCONFIG)
	@printf "\e[1;32mBuilding kernel...\e[0m\n"
	@$(MAKE) -f Makefile O=out CC=clang

fastboot: all
	@printf "\e[1;32mBooting out/arch/arm64/boot/Image.gz-dtb...\e[0m\n"
	@fastboot boot out/arch/arm64/boot/Image.gz-dtb
	@printf "\e[36mWaiting for device to boot...\e[0m\n"
	@adb wait-for-device
	@printf "\e[1;32mRequesting dmesg...\e[0m\n"
	@adb shell su -c dmesg

.PHONY: all default fastboot GNUmakefile
