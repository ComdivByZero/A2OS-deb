#!/bin/bash

NAME=a2os
VERSION=1.7d61aad6.0
HOMEPAGE=http://cas.inf.ethz.ch/projects/a2
MAINTAINER_0="Comdiv <ComdivByZero@yandex.ru>"

TMP=/tmp/a2os-make-deb
A2OS=$TMP/$NAME-$VERSION
DEBIAN=$A2OS/DEBIAN
DOC=$A2OS/usr/share/doc/$NAME
A2P=/usr/lib/a2os
A2SH=/usr/bin/a2os
CURD="$(pwd)"

copy() {
    local LINUX=$1

    cp -r source $LINUX $A2OS$A2P/
    rm $A2OS$A2P/$LINUX/a2.sh
    cp a2os $A2OS$A2SH

    cd $A2OS

    find . -type f -exec chmod 644 {} ';'
    find . -type d -exec chmod 755 {} ';'
    chmod 755 $A2OS$A2SH $A2OS$A2P/$LINUX/oberon
}

makedeb() {
    local ARCH=$1
    local DEB=$A2OS-$ARCH.deb

    md5deep -rl usr > DEBIAN/md5sums
    chmod 644 DEBIAN/md5sums
    cd ..
    fakeroot dpkg-deb --build *
    cd "$CURD"
    mv $A2OS.deb $DEB
    echo Built $DEB
    lintian $DEB

    mv $DEB ./

    rm -fr $TMP
}

init() {
    rm -fr $TMP
    mkdir -p $A2OS$A2P $A2OS/usr/bin $DEBIAN $DOC
}

makeControl() {
    local LINUX=$1
    local ARCH=$2

    local SIZE=$(du -a $LINUX | tail -n 1 | awk '{print $1}')

    cat > $DEBIAN/control << EOF
Source: ${NAME}
Section: devel
Maintainer: ${MAINTAINER_0}
Homepage: ${HOMEPAGE}
Package: ${NAME}
Version: ${VERSION}
Priority: optional
Installed-Size: ${SIZE}
Architecture: ${ARCH}
Depends: libc6
Recommends: libx11-6, libnotify-bin
Description: A2 Operating System, written on Active Oberon
 Operating System, written in ETH on Active Oberon.
 Also available as an application under host OS.
EOF
}

makeChangelogAndCopyright() {
    gzip -9cn - > $DOC/changelog.gz << EOF
 ${NAME} (1.7d61aad6.0) unstable; urgency=low
  * Basic Unix AR archive packing and unpacking

 -- ${MAINTAINER_0} Monday, 20 Jun 2022 00:00:00 +0200

 ${NAME} (0.9f0e6936.0) unstable; urgency=low
  * Initial package

 -- ${MAINTAINER_0} Monday, 20 Jun 2022 00:00:00 +0200
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
}

make() {
    local LINUX=$1
    local ARCH=$2

    init &&
    makeControl $LINUX $ARCH &&
    makeChangelogAndCopyright &&
    copy $LINUX &&
    makedeb $ARCH
}

make Linux64 amd64
make Linux32 i386
