#!/bin/sh

SCRIPT_FILE=`realpath "$0"`
SCRIPT_DIR=`dirname "$SCRIPT_FILE"`
BASE_DIR=`dirname "$SCRIPT_DIR"`

if [ ! -d "$HOME/.config/OpenToonz" ]; then
    mkdir -p $HOME/.config/OpenToonz
    cp -r $BASE_DIR/share/openttoonz/stuff $HOME/.config/OpenToonz/

cat << EOF > $HOME/.config/OpenToonz/SystemVar.ini
[General]
OPENTOONZROOT="$HOME/.config/OpenToonz/stuff"
OpenToonzPROFILES="$HOME/.config/OpenToonz/stuff/profiles"
TOONZCACHEROOT="$HOME/.config/OpenToonz/stuff/cache"
TOONZCONFIG="$HOME/.config/OpenToonz/stuff/config"
TOONZFXPRESETS="$HOME/.config/OpenToonz/stuff/projects/fxs"
TOONZLIBRARY="$HOME/.config/OpenToonz/stuff/projects/library"
TOONZPROFILES="$HOME/.config/OpenToonz/stuff/profiles"
TOONZPROJECTS="$HOME/.config/OpenToonz/stuff/projects"
TOONZROOT="$HOME/.config/OpenToonz/stuff"
TOONZSTUDIOPALETTE="$HOME/.config/OpenToonz/stuff/projects/studiopalette"
EOF

fi

export LD_LIBRARY_PATH="$BASE_DIR/lib:$BASE_DIR/lib64:$LD_LIBRARY_PATH"
export QT_XKB_CONFIG_ROOT=$QT_XKB_CONFIG_ROOT:/usr/local/share/X11/xkb:/usr/share/X11/xkb

OLDDIR=$(cd `dirname "$0"`; pwd)
cd "$BASE_DIR/bin"
./opentoonz
cd "$OLDDIR"
