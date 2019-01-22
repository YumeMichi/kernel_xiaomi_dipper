# SPDX-License-Identifier: MIT
# Copyright (C) 2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.

MAKEFLAGS += --no-print-directory
ifeq ($(findstring -j,$(MAKEFLAGS)),)
MAKEFLAGS += -j$(shell nproc)
endif

default: all

TARGET_DEFCONFIG ?= dipper_defconfig

GCC_VERSION ?= 8.1.0
TOOLCHAIN_HOST ?= https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin
HOST_ARCH := $(shell uname -m)
define toolchain
toolchains/gcc-$(GCC_VERSION)-nolibc/$(1)/.prepared:
	@printf "\e[1;32mDownloading gcc $(GCC_VERSION) for $(1)...\e[0m\n"
	@mkdir -p toolchains
	@curl --progress-bar $(TOOLCHAIN_HOST)/$(HOST_ARCH)/$(GCC_VERSION)/$(HOST_ARCH)-gcc-$(GCC_VERSION)-nolibc-$(1).tar.xz | tar -C toolchains -xJf -
	@touch $$@
all: toolchains/gcc-$(GCC_VERSION)-nolibc/$(1)/.prepared
%:: toolchains/gcc-$(GCC_VERSION)-nolibc/$(1)/.prepared
endef

ifeq ($(CROSS_COMPILE),)
$(eval $(call toolchain,aarch64-linux))
$(eval $(call toolchain,arm-linux-gnueabi))
export CROSS_COMPILE=$(CURDIR)/toolchains/gcc-$(GCC_VERSION)-nolibc/aarch64-linux/bin/aarch64-linux-
export CROSS_COMPILE_ARM32=$(CURDIR)/toolchains/gcc-$(GCC_VERSION)-nolibc/arm-linux-gnueabi/bin/arm-linux-gnueabi-
endif
export ARCH=arm64

all:
	@printf "\e[1;32mGenerating configuration...\e[0m\n"
	@$(MAKE) -f Makefile O=out $(TARGET_DEFCONFIG)
	@printf "\e[1;32mBuilding kernel...\e[0m\n"
	@$(MAKE) -f Makefile O=out

clean-toolchains:
	@printf "\e[1;32mCleaning toolchains...\e[0m\n"
	@$(RM) -rfv toolchains

fastboot: all
	@printf "\e[1;32mBooting out/arch/arm64/boot/Image.gz-dtb...\e[0m\n"
	@fastboot boot out/arch/arm64/boot/Image.gz-dtb
	@printf "\e[36mWaiting for device to boot...\e[0m\n"
	@adb wait-for-device
	@printf "\e[1;32mRequesting dmesg...\e[0m\n"
	@adb shell su -c dmesg

.PHONY: clean-toolchains all default fastboot GNUmakefile
