#!/bin/bash

NAME=a2os
VERSION=0.9f0e6936.0
HOMEPAGE=http://cas.inf.ethz.ch/projects/a2
MAINTAINER_0="Comdiv <ComdivByZero@yandex.ru>"

SIZE=$(du -a Linux64 | tail -n 1 | awk '{print $1}')

TMP=/tmp/a2os-make-deb
A2OS=$TMP/$NAME-$VERSION
DEBIAN=$A2OS/DEBIAN
DOC=$A2OS/usr/share/doc/$NAME
A2P=/usr/lib/a2os
A2SH=/usr/bin/a2os
CURD="$(pwd)"

copy() {
    cp -r source Linux64 $A2OS$A2P/
    rm $A2OS$A2P/Linux64/a2.sh
    cp a2os $A2OS$A2SH

    cd $A2OS

    find . -type f -exec chmod 644 {} ';'
    find . -type d -exec chmod 755 {} ';'
    chmod 755 $A2OS$A2SH $A2OS$A2P/Linux64/oberon
}

makedeb() {
    md5deep -rl usr > DEBIAN/md5sums
    chmod 644 DEBIAN/md5sums
    cd ..
    fakeroot dpkg-deb --build *
    cd "$CURD"
    echo Built $A2OS.deb
    lintian $A2OS.deb
}

rm -fr $TMP
mkdir -p $A2OS$A2P $A2OS/usr/bin $DEBIAN $DOC

cat > $DEBIAN/control << EOF
Source: ${NAME}
Section: devel
Maintainer: ${MAINTAINER_0}
Homepage: ${HOMEPAGE}
Package: ${NAME}
Version: ${VERSION}
Priority: optional
Installed-Size: ${SIZE}
Architecture: amd64
Depends: libc6
Recommends: libx11-6
Description: A2 Operating System, written on Active Oberon
 Operating System, written in ETH on Active Oberon.
 Also available as an application under host OS.
EOF

gzip -9cn - > $DOC/changelog.gz << EOF
 ${NAME} (0.9f0e6936.0) unstable; urgency=low
  * Initial package

 -- ${MAINTAINER_1} Monday, 20 Jun 2022 00:00:00 +0200
EOF

cat > $DOC/copyright << EOF
Format: http://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: ${NAME}
Source: ${HOMEPAGE}
Files: *
Copyright: 2002-2016, Computer Systems Institute, ETH Zurich
1993-2002 Project Voyager, StatLab Heidelberg ; (C) 1993-2002 G. Sawitzki et al.
1997-2002 Felix Friedrich, Munich:

License: LGPL-2.1

EOF
cat license.txt > $DOC/copyright

copy
makedeb
