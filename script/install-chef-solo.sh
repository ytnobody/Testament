#!/bin/sh

GEM=$(which gem)
CHEF=$(which chef)
KNIFE=$(which knife)

RBENV_ROOT=$HOME/.rbenv
PROF_FILE=$HOME/.profile
RBENV_PLUGIN_DIR=$RBENV_ROOT/plugins
RUBY_VERSION=1.9.3-p429

die () {
    echo $1 >&2
    exit 1
}

write_profile () {
    if [ $(grep "$1" $PROF_FILE | wc -l) -le 0 ] ; then
        echo "$1" >> $PROF_FILE
    fi
}

if [ -z "$GEM" ]; then 
    ### setup rbenv
    write_profile 'export RBENV_ROOT=$HOME/.rbenv'
    write_profile 'export PATH=$PATH:$RBENV_ROOT/bin'
    write_profile 'eval "$(rbenv init -)"'

    ### load profile
    . $PROF_FILE 

    ### install ruby
    rbenv install $RUBY_VERSION
    rbenv global $RUBY_VERSION
    
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

