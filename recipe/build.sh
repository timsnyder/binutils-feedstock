#!/bin/bash

set -e

for file in ./crosstool_ng/packages/binutils/$PKG_VERSION/*.patch; do
  patch -p1 < $file;
done

mkdir build
cd build

../configure \
  --prefix="$PREFIX" \
  --target=$HOST \
  --with-sysroot=$BUILD_PREFIX/$HOST/sysroot \
  --enable-ld=default \
  --enable-gold=yes \
  --enable-plugins \
  --disable-multilib \
  --disable-sim \
  --disable-gdb \
  --disable-nls

make -j${CPU_COUNT}
