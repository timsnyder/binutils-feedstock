#!/bin/bash

set -e

for file in ./crosstool_ng/packages/binutils/$PKG_VERSION/*.patch; do
  patch -p1 < $file;
done

mkdir build
cd build

../configure --prefix="$PREFIX" --enable-gold --target=$HOST
make -j${CPU_COUNT}
