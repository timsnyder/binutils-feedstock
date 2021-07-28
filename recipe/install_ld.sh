#!/bin/bash

set -e

cd build

make DESTDIR=$PWD/install install-strip

CHOST="${ctng_cpu_arch}-conda-linux-gnu"
OLD_CHOST="${ctng_cpu_arch}-${ctng_vendor}-linux-gnu"
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/$OLD_CHOST/bin
mkdir -p $PREFIX/$CHOST/bin
if [[ "$target_platform" == "$ctng_target_platform" ]]; then
  cp $PWD/install/$PREFIX/bin/ld $PREFIX/bin/$CHOST-ld
else
  cp $PWD/install/$PREFIX/bin/$CHOST-ld $PREFIX/bin/$CHOST-ld
fi
ln -s $PREFIX/bin/$CHOST-ld $PREFIX/bin/$OLD_CHOST-ld
ln -s $PREFIX/bin/$CHOST-ld $PREFIX/$OLD_CHOST/bin/ld
ln -s $PREFIX/bin/$CHOST-ld $PREFIX/$CHOST/bin/ld
