#!/bin/bash

VERSION="R1-$(date +%F | sed s@-@@g)"

if [ -e out/arch/arm64/boot/Image.gz-dtb ] ; then
    # Pack AnyKernel2
    rm -rf PolarKernel-$VERSION 2> /dev/null
    cp out/arch/arm64/boot/Image.gz-dtb anykernel2

    cd anykernel2
    zip -r9 ../PolarKernel-$VERSION.zip * -x README.md

    cd ..
    ls -l PolarKernel-$VERSION.zip
fi
