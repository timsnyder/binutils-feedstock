#!/bin/bash

CHOST="${ctng_cpu_arch}-conda-linux-gnu"

# The minimal set of flags that need to be applied for these short names to just do what I want
# are:
#LDFLAGS=(-Wl,-rpath,"${PREFIX}/lib" -Wl,-rpath-link,"${PREFIX}/lib" -L"${PREFIX}/lib") 
# the standard way we set LDFLAGS works when the makefiles call gcc driver but not if they
# call ld directly becasue -Wl is the driver option, not linker option
LDFLAGS=(-rpath "${PREFIX}/lib" -rpath-link "${PREFIX}/lib" -L"${PREFIX}/lib") 

# So, for the commands that need those flags, install tiny wrapper scripts that inject them

wrapit() {
    long=$1
    shift
    short=$1
    shift

    # NOTE the importance of tab characters in the <<- HEREDOC, i.e. they will be dedented
	cat > $short <<-END_WRAP
	#!${PREFIX}/bin/bash

	exec $long $@ "\$@"
	END_WRAP
}

for tool in addr2line ar as c++filt dwp elfedit gprof nm objcopy objdump ranlib readelf size strings strip; do
  rm $PREFIX/bin/$CHOST-$tool
  touch $PREFIX/bin/$CHOST-$tool
  ln -s $PREFIX/bin/$CHOST-$tool $PREFIX/bin/$tool
done
for tool in ld ld.bfd ld.gold; do
  rm $PREFIX/bin/$CHOST-$tool
  touch $PREFIX/bin/$CHOST-$tool
  wrapit $PREFIX/bin/$CHOST-$tool $PREFIX/bin/$tool "${LDFLAGS[@]}"
done
# Thanks for being special ld.gold.  It doesn't understand -rpath-link, it needs an extra '-' on the front of it, i.e. --rpath-link
LDFLAGS=${LDFLAGS[@]/-rpath-link/--rpath-link}
for tool in ld.gold; do
  rm $PREFIX/bin/$CHOST-$tool
  touch $PREFIX/bin/$CHOST-$tool
  wrapit $PREFIX/bin/$CHOST-$tool $PREFIX/bin/$tool "${LDFLAGS[@]}"
done

ln -s "$PREFIX/bin/ld.gold" "$PREFIX/bin/gold"
