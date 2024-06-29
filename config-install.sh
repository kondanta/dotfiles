#!/bin/bash

WORKING_DIR=$(pwd)
TARGET_DIR=$HOME/.config

mkdir -p $TARGET_DIR
git init --bare $TARGET_DIR

ls $WORKING_DIR/.config | xargs -I {} cp -R $WORKING_DIR/.config/{} $TARGET_DIR/{}

echo "Copied config files to $TARGET_DIR"


# Set firefox profile
if [[ ! -z $(which firefox)]]; then
    firefox -CreateProfile "home $HOME/.mozilla/firefox/profiles"
    echo "Created firefox profile 'home' in $HOME/.mozilla/firefox/profiles"
fi

git submodule update --init --recursive
cp -R $TARGET_DIR/firefox-config/{user.js,chrome/} $HOME/.mozilla/firefox/profiles/home/