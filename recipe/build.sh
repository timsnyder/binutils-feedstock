#!/bin/bash

set -e


#pushd ${BUILD_PREFIX}/bin
#  for fn in "${BUILD}-"*; do
#    new_fn=${fn//${BUILD}-/}
#    echo "Creating symlink from ${fn} to ${new_fn}"
#    ln -sf "${fn}" "${new_fn}"
#    varname=$(basename "${new_fn}" | tr a-z A-Z | sed "s/+/X/g" | sed "s/\./_/g" | sed "s/-/_/g")
#    echo "$varname $CC"
#    printf -v "$varname" "$BUILD_PREFIX/bin/${new_fn}"
#  done
#popd

get_cpu_arch() {
  local CPU_ARCH
  if [[ "$1" == *"-64" ]]; then
    CPU_ARCH="x86_64"
  elif [[ "$1" == *"-ppc64le" ]]; then
    CPU_ARCH="powerpc64le"
  elif [[ "$1" == *"-aarch64" ]]; then
    CPU_ARCH="aarch64"
  elif [[ "$1" == *"-s390x" ]]; then
    CPU_ARCH="s390x"
  else
    echo "Unknown architecture"
    exit 1
  fi
  echo $CPU_ARCH
}

get_triplet() {
  if [[ "$1" == linux-* ]]; then
    echo "$(get_cpu_arch $1)-conda-linux-gnu"
  elif [[ "$1" == osx-64 ]]; then
    echo "x86_64-apple-darwin13.4.0"
  elif [[ "$1" == osx-arm64 ]]; then
    echo "arm64-apple-darwin20.0.0"
  else
    echo "unknown platform"
  fi
}

for file in ./crosstool_ng/packages/binutils/${PKG_VERSION}/*.patch; do
  patch -p1 < $file;
done

# Fix permissions on license files--not sure why these are world-writable, but that's how
# they come from the upstream tarball
chmod og-w COPYING*

mkdir build
cd build

if [[ "$target_platform" == osx-arm64 ]]; then
  OSX_ARCH="arm64"
elif [[ "$target_platform" == osx-64 ]]; then
  OSX_ARCH="x86_64"
fi
if [[ "$target_platform" == osx-* ]]; then
  export CPPFLAGS="$CPPFLAGS -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} -arch ${OSX_ARCH}"
  export CFLAGS="$CFLAGS -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} -arch ${OSX_ARCH}"
  export CXXFLAGS="$CXXFLAGS -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} -arch ${OSX_ARCH}"
  export LDFLAGS="$LDFLAGS -Wl,-pie -Wl,-headerpad_max_install_names -Wl,-dead_strip_dylibs -arch ${OSX_ARCH}"
fi

export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"

export BUILD="$(get_triplet $build_platform)"
export HOST="$(get_triplet $target_platform)"
export TARGET="$(get_triplet $ctng_target_platform)"

if [[ "$target_platform" != "$build_platform" && "$target_platform" == linux-* ]]; then
  # Since we might not have libgcc-ng packaged yet, let's statically link in libgcc
  export LDFLAGS="$LDFLAGS -static-libgcc -static-libstdc++"
fi

# Workaround a problem in conda-build. xref https://github.com/conda/conda-build/pull/4253
if [[ -d $BUILD_PREFIX/$HOST/sysroot/usr/lib64 && ! -d $BUILD_PREFIX/$HOST/sysroot/usr/lib ]]; then
  mkdir -p $BUILD_PREFIX/$HOST/sysroot/usr
  ln -sf $BUILD_PREFIX/$HOST/sysroot/usr/lib64 $BUILD_PREFIX/$HOST/sysroot/usr/lib
fi
if [[ -d $BUILD_PREFIX/$HOST/sysroot/lib64 && ! -d $BUILD_PREFIX/$HOST/sysroot/lib ]]; then
  mkdir -p $BUILD_PREFIX/$HOST/sysroot
  ln -sf $BUILD_PREFIX/$HOST/sysroot/lib64 $BUILD_PREFIX/$HOST/sysroot/lib
fi

../configure \
  --prefix="$PREFIX" \
  --build=$BUILD \
  --host=$HOST \
  --target=$TARGET \
  --enable-ld=default \
  --enable-gold=yes \
  --enable-plugins \
  --disable-multilib \
  --disable-sim \
  --disable-gdb \
  --disable-nls \
  --enable-default-pie \
  --with-sysroot=$PREFIX/$HOST/sysroot \
  $CONFIG_ARGS || (cat config.log; false)

make -j${CPU_COUNT}

#exit 1
