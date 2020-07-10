#!/bin/bash

set -e

cd build

make DESTDIR=$PWD/install install-strip

CHOST="${ctng_cpu_arch}-${ctng_vendor}-linux-gnu"
NEW_CHOST="${ctng_cpu_arch}-conda-linux-gnu"
mkdir -p $PREFIX/bin
cp $PWD/install/$PREFIX/bin/$CHOST-ld $PREFIX/bin/$CHOST-ld
ln -s $PREFIX/bin/$CHOST-ld $PREFIX/bin/$NEW_CHOST-ld
