#!/bin/sh

GEM=$(which gem)
CHEF=$(which chef)
KNIFE=$(which knife)

RBENV_REPO=git://github.com/sstephenson/rbenv.git
RBENV_ROOT=$HOME/.rbenv
PROF_FILE=$HOME/.profile

RUBYBUILDER_REPO=git://github.com/sstephenson/ruby-build.git
RBENV_PLUGIN_DIR=$RBENV_ROOT/plugins

die () {
    echo $1 >&2
    exit 1
}

write_profile () {
    if [ $(grep "$1" $PROF_FILE | wc -l) -le 0 ] ; then
        echo "$1" >> $PROF_FILE
    fi
}

git --version || die "git is not installed."

if [ -z "$GEM" ]; then 
    ### setup rbenv
    git clone $RBENV_REPO $RBENV_ROOT || die "git clone failure : $RBENV_REPO"
    write_profile 'export RBENV_ROOT=$HOME/.rbenv'
    write_profile 'export PATH=$PATH:$RBENV_ROOT/bin'
    write_profile 'eval "$(rbenv init -)"'

    ### setup ruby-builder
    mkdir $RBENV_PLUGIN_DIR
    git clone $RUBYBUILDER_REPO $RBENV_PLUGIN_DIR/ruby-build || die "git clone failure : $RUBYBUILDER_REPO"

    ### load profile
    . $PROF_FILE 
    GEM=$(which gem)
fi

if [ -z "$GEM" ]; then
    die "failure to install gem"
fi

if [ -z "$CHEF" ] ; then
    $GEM i chef --no-ri --no-rdoc
    CHEF=$(which chef)
    KNIFE=$(which knife)
    $KNIFE configure
    $GEM i knife-solo --no-ri --no-rdoc
    echo "install finished."
else
    echo "already installed."
fi

