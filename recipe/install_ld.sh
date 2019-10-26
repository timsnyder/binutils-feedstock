#!/bin/bash

set -e

cd build

make DESTDIR=$PWD/install install-strip

mkdir -p $PREFIX/bin
cp $PWD/install/$PREFIX/bin/$HOST-ld $PREFIX/bin/$HOST-ld
