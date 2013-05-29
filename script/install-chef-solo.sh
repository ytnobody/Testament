#!/bin/sh

PKG_ADD=$(which pkg_add)
APT_GET=$(which apt-get)
GEM=$(which gem)
CHEF=$(which chef)
KNIFE=$(which knife)

die () {
    echo $1 >&2
    exit 1
}

if [ $(whoami) != "root" ]; then
    die "exec by super-user"
fi

if [ -z "$PKG_ADD" ] && [ -z "$APT_GET" ]; then
    die "apt-get and pkg_add not found"
fi

if [ -z "$GEM" ]; then 
    if [ ! -z "$PKG_ADD" ]; then
        $PKG_ADD ruby-gems
        ln -sf /usr/local/bin/ruby18 /usr/local/bin/ruby
        ln -sf /usr/local/bin/erb18 /usr/local/bin/erb
        ln -sf /usr/local/bin/irb18 /usr/local/bin/irb
        ln -sf /usr/local/bin/rdoc18 /usr/local/bin/rdoc
        ln -sf /usr/local/bin/ri18 /usr/local/bin/ri
        ln -sf /usr/local/bin/testrb18 /usr/local/bin/testrb
        ln -sf /usr/local/bin/gem18 /usr/local/bin/gem
    elif [ ! -z "$APT_GET" ]; then
        $APT_GET install ruby rubygems
    fi
    GEM=$(which gem)
fi

if [ -z "$GEM" ]; then
    die "failure to install rubygems"
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

