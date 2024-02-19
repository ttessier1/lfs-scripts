#!/bin/bash 
# As found from:
# https://www.linuxfromscratch.org/blfs/downloads/stable/BLFS-BOOK-12.0-nochunks.html#xorg7-font
# Added directory checks

as_root()
{
	if   [ $EUID = 0 ];        then $*
	elif [ -x /usr/bin/sudo ]; then sudo $*
	else                            su -c \\"$*\\"
	fi
}

export -f as_root

set -e

for package in $(grep -v '^#' ../font-7.md5 | awk '{print $2}')
do
	unset SUCCESS
	packagedir=${package%.tar.?z*}
	if [ ! -d $packagedir ]; then
		tar -xf $package
	fi
	pushd $packagedir
	./configure $XORG_CONFIG &&
	make &&
	as_root make install &&
	popd &&
	as_root rm -rf $packagedir &&
	echo "Package Built" &&
	export SUCCESS="True"
	if [ "$SUCCESS" = "True" ]; then
		continue
	else
		echo "Failed to build package: $package"
		exit 1
	fi
done
exit 0