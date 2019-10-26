#!/bin/bash

set -e

for file in ./crosstool_ng/packages/binutils/$PKG_VERSION/*.patch; do
  patch -p1 < $file;
done

mkdir build
cd build

../configure --prefix="$PREFIX" --enable-gold --target=$HOST
make -j${CPU_COUNT}
make install-strip

# Remove hardlinks and replace them by softlinks
for tool in addr2line ar as c++filt dwp elfedit gprof ld ld.bfd ld.gold nm objcopy objdump ranlib readelf size strings strip; do
  rm -rf $PREFIX/$HOST/bin/$tool
  ln -sf $PREFIX/bin/$HOST-$tool $PREFIX/$HOST/bin/$tool
done
