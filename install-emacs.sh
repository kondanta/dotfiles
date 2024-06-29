#!/bin/bash


# We need git for installation. Check if git's already installed or not.
git --version 2>&1 >/dev/null # improvement by tripleee
GIT_IS_AVAILABLE=$?

if [ $GIT_IS_AVAILABLE -ne 0 ]; then
    echo "Git is not available"
    return 1
fi

REMOTE_URL="git@github.com:emacs-mirror/emacs.git"
git clone $REMOTE_URL && cd emacs

LATEST=$(git tag | grep -o emacs-[0-9]+.[0-9]+ | tail -1)
git checkout $LATEST

OPTIONS='--with-wide-int --with-cairo --with-modules --enable-link-time-optimization --with-x-toolkit=lucid --with-mailutils --with-imagemagick --enable-autodepend --with-libsystemd'

./autogen.sh && ./configure $OPTIONS

make

sudo make install