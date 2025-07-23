#!/bin/bash

WORKING_DIR=$(pwd)
TARGET_DIR=$HOME/.config

mkdir -p $TARGET_DIR
git init --bare $TARGET_DIR

ls $WORKING_DIR/config | xargs -I {} cp -R $WORKING_DIR/config/{} $TARGET_DIR/{}

echo "Copied config files to $TARGET_DIR"


# Set firefox profile
if [[ ! -z $(which firefox) ]]; then
    firefox -CreateProfile "home $HOME/.mozilla/firefox/profiles"
    echo "Created firefox profile 'home' in $HOME/.mozilla/firefox/profiles"
fi

# Trigger submodule update
/bin/bash -c "$TARGET_DIR/user-scripts/submodule-updater"

# Add it to the crontab to work every day at 2 pm
(crontab -l 2>/dev/null; echo "0 14 * * * /bin/bash -c $TARGET_DIR/user-scripts/submodule-updater") | crontab -

# Put dwm config into correct place
rm -f $HOME/.local/src/dwm/config.h && ln -s $TARGET_DIR/custom-dwm/config.h $HOME/.local/src/dwm/config.h
