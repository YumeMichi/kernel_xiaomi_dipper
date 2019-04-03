# SPDX-License-Identifier: MIT
# Copyright (C) 2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.

MAKEFLAGS += --no-print-directory
ifeq ($(findstring -j,$(MAKEFLAGS)),)
MAKEFLAGS += -j$(shell nproc)
endif

default: all

TARGET_DEFCONFIG := dipper_defconfig

GCC_VERSION := 8.1.0
TOOLCHAIN_HOST := https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin
HOST_ARCH := $(shell uname -m)

CLANG_VERSION := 9.0.2 (based on r353983b)
CLANG_BUILD_VERSION := 5407736
CLANG_PREBUILT_GIT := https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-$(CLANG_BUILD_VERSION).git

define gcctoolchain
toolchains/gcc-$(GCC_VERSION)-nolibc/$(1)/.prepared:
	@printf "\e[1;32mDownloading gcc $(GCC_VERSION) for $(1)...\e[0m\n"
	@mkdir -p toolchains
	@curl --progress-bar $(TOOLCHAIN_HOST)/$(HOST_ARCH)/$(GCC_VERSION)/$(HOST_ARCH)-gcc-$(GCC_VERSION)-nolibc-$(1).tar.xz | tar -C toolchains -xJf -
	@touch $$@
all: toolchains/gcc-$(GCC_VERSION)-nolibc/$(1)/.prepared
%:: toolchains/gcc-$(GCC_VERSION)-nolibc/$(1)/.prepared
endef

define clangtoolchain
toolchains/clang-$(CLANG_BUILD_VERSION)/.prepared:
	@printf "\e[1;32mDownloading clang $(CLANG_VERSION) ...\e[0m\n"
	@mkdir -p toolchains
	@git clone --depth=1 --progress $(CLANG_PREBUILT_GIT) toolchains/clang-$(CLANG_BUILD_VERSION)
	@touch $$@

all: toolchains/clang-$(CLANG_BUILD_VERSION)/.prepared

%:: toolchains/clang-$(CLANG_BUILD_VERSION)/.prepared
endef

ifeq ($(CROSS_COMPILE),)
$(eval $(call clangtoolchain,))
$(eval $(call gcctoolchain,aarch64-linux))
$(eval $(call gcctoolchain,arm-linux-gnueabi))
TOOLCHAIN_PATH := $(PATH):$(CURDIR)/toolchains/clang-$(CLANG_BUILD_VERSION)/bin:$(CURDIR)/toolchains/gcc-$(GCC_VERSION)-nolibc/aarch64-linux/bin:$(CURDIR)/toolchains/gcc-$(GCC_VERSION)-nolibc/arm-linux-gnueabi/bin
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
endif

export ARCH=arm64
export PATH=$(TOOLCHAIN_PATH)

all:
	@printf "\e[1;32mGenerating configuration...\e[0m\n"
	@$(MAKE) -f Makefile O=out CC=clang $(TARGET_DEFCONFIG)
	@printf "\e[1;32mBuilding kernel...\e[0m\n"
	@$(MAKE) -f Makefile O=out CC=clang

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
