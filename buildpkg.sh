#!/bin/sh

#This script builds the tarball, single-file script, and Debian package (experimental) for MultiCD.

VERSION=$(./multicd.sh -V)

#build tarball
tar -cvzf multicd-$VERSION.tar.gz buildpkg.sh changelog.txt combine.sh functions.sh multicd.sh plugins plugins.md5

#build combined .sh
./combine.sh multicd-$VERSION.sh

#build debian package
TEMPDIR=mcdpackage-$VERSION
mkdir -p $TEMPDIR/DEBIAN $TEMPDIR/usr/bin $TEMPDIR/usr/share/multicd $TEMPDIR/usr/share/doc/multicd $TEMPDIR/usr/share/icons/hicolor/scalable/apps $TEMPDIR/usr/share/applications $TEMPDIR/usr/share/man/man1
cp multicd.sh $TEMPDIR/usr/bin/multicd
sed -i -e 's^MCDDIR="\."^MCDDIR="/usr/share/multicd\"^g' $TEMPDIR/usr/bin/multicd
cp -r functions.sh plugins plugins.md5 $TEMPDIR/usr/share/multicd
cp buildpkg.sh changelog.txt combine.sh isos.txt $TEMPDIR/usr/share/doc/multicd
cp multicd.svg $TEMPDIR/usr/share/icons/hicolor/scalable/apps

echo "[Desktop Entry]
Version=1.0
Terminal=false
Exec=multicd gui
Icon=multicd
Type=Application
Categories=Application;Utility;System;
Name=MultiCD
Comment=Build a custom CD/DVD/USB image from multiple live CDs" > $TEMPDIR/usr/share/applications/multicd.desktop

cat manpage | sed -e "s/UNKNOWN_DATE/$(date +'%B %d, %Y')/g" -e "s/MCD_VER/$VERSION/g" | gzip -c > $TEMPDIR/usr/share/man/man1/multicd.1.gz

echo "This package was debianized by an automated script ($0)
on $(date -u).

MultiCD main script copyright:

Copyright (c) 2012 Isaac Schemm

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

See the plugin .sh files for copyright information. At the moment, they all
use the same license, but occasionally have different authors.

The multicd.svg icon was made by Isaac Schemm using icons from the Tango
Desktop Project (http://tango.freedesktop.org) as a base. It is public domain.
" > $TEMPDIR/usr/share/doc/multicd/copyright

echo "Package: multicd
Version: $VERSION
Section: utils
Priority: optional
Architecture: all
Depends: bash, linux-image | fuseiso | ark | file-roller, genisoimage | mkisofs, awk, sed
Recommends: dialog, wget, fuseiso, zenity
Installed-Size: $(du $TEMPDIR/usr --apparent-size --total|tail -n 1|awk '{print $1}')
Maintainer: Isaac Schemm <isaacschemm@gmail.com>
Description: Shell script to build live CDs/DVDs from one or more images
 MultiCD is a bash script that uses plugin files to copy data from several ISO images into a new multiboot ISO image. It also supports any floppy disk image.
" > $TEMPDIR/DEBIAN/control

cd $TEMPDIR
md5sum $(find usr -type f) > DEBIAN/md5sums
chown -R root.root usr
cd -
dpkg-deb -b $TEMPDIR multicd_${VERSION}_all.deb
rm -r $TEMPDIR
