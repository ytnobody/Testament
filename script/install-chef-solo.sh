#!/bin/sh

PKG_ADD=$(which pkg_add)
APT_GET=$(which apt-get)
GEM=$(which gem)
CHEF=$(which chef)
KNIFE=$(which knife)

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

if [ -z "$GEM" ]; then 
    if [ ! -z "$PKG_ADD" ]; then
        $PKG_ADD ruby
    elif [ ! -z "$APT_GET" ]; then
        $APT_GET install ruby 
    fi
    GEM=$(which gem)
fi

if [ -z "$CHEF" ] ; then
    $GEM i chef --no-ri --no-rdoc
    CHEF=$(which chef)
    KNIFE=$(which knife)
    $KNIFE configure
    $GEM i knife-solo --no-ri --no-rdoc
    echo "done."
else
    echo "already installed."
fi

