#!/bin/sh

PKG_ADD=$(which pkg_add)
APT_GET=$(which apt-get)

die () {
    echo $1 >2&
    exit 1
}

if [ $(whoami) != "root" ]; then
    die "exec by super-user"
fi

if [ -z "$PKG_ADD" && -z "$APT_GET" ]; then
    die "apt-get and pkg_add not found"
fi

if [ ! -z "$PKG_ADD" ]; then
    $PKG_ADD ruby
    $PKG_ADD chef
elif [ ! -z "$APT_GET" ]; then
    $APT_GET install chef
fi
