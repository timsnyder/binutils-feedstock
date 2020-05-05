#!/bin/bash

set -e

cd build

make install-strip
export HOST="${ctng_cpu_arch}-conda-linux-gnu"
export OLD_HOST="${ctng_cpu_arch}-${ctng_vendor}-linux-gnu"
# Remove hardlinks and replace them by softlinks
for tool in addr2line ar as c++filt dwp elfedit gprof ld ld.bfd ld.gold nm objcopy objdump ranlib readelf size strings strip; do
  rm -rf $PREFIX/$HOST/bin/$tool
  ln -s $PREFIX/bin/$HOST-$tool $PREFIX/$HOST/bin/$tool || true;
  ln -s $PREFIX/bin/$HOST-$tool $PREFIX/bin/$OLD_HOST-$tool || true;
done

#ln -s $PREFIX/$HOST $PREFIX/$OLD_HOST
