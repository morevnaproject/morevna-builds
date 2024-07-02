#!/bin/sh

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
BASE_DIR=`dirname "$SCRIPT_DIR"`

export LD_LIBRARY_PATH="$BASE_DIR/lib:$BASE_DIR/lib/opentoonz:$BASE_DIR/lib64:$LD_LIBRARY_PATH"
export XCURSOR_PATH="$BASE_DIR/share/icons:$XCURSOR_PATH:/usr/local/share/icons:/usr/share/icons"
export QT_XKB_CONFIG_ROOT="$QT_XKB_CONFIG_ROOT:/usr/local/share/X11/xkb:/usr/share/X11/xkb"

# fix stuff
CONFIG_DIR="$HOME/.config/OpenToonz"
if [ ! -d "$CONFIG_DIR" ]; then
    echo "fix config: copy stuff".
    mkdir -p "$CONFIG_DIR"
    cp -r "$BASE_DIR/share/opentoonz/stuff" "$CONFIG_DIR"

    echo "fix config: create SystemVar.ini" 
    cat << EOF > "$CONFIG_DIR/SystemVar.ini"
[General]
OPENTOONZROOT="$HOME/.config/OpenToonz/stuff"
OpenToonzPROFILES="$HOME/.config/OpenToonz/stuff/profiles"
TOONZCACHEROOT="$HOME/.config/OpenToonz/stuff/cache"
TOONZCONFIG="$HOME/.config/OpenToonz/stuff/config"
TOONZFXPRESETS="$HOME/.config/OpenToonz/stuff/fxs"
TOONZLIBRARY="$HOME/.config/OpenToonz/stuff/library"
TOONZPROFILES="$HOME/.config/OpenToonz/stuff/profiles"
TOONZPROJECTS="$HOME/.config/OpenToonz/stuff/projects"
TOONZROOT="$HOME/.config/OpenToonz/stuff"
TOONZSTUDIOPALETTE="$HOME/.config/OpenToonz/stuff/studiopalette"
EOF

else
    # fix paths
    INI="$HOME/.config/OpenToonz/SystemVar.ini"
    if [ -e "$INI" ]; then
        [ -e "$INI.bak" ] || cp "$INI" "$INI.bak"

        # fix path to studiopalette
        FX_PATH_OLD="$CONFIG_DIR/stuff/projects/studiopalette"
        FX_PATH_NEW="$CONFIG_DIR/stuff/studiopalette"
        FX_LINE_OLD="TOONZFXPRESETS=\"$FX_PATH_OLD\""
        FX_LINE_NEW="TOONZFXPRESETS=\"$FX_PATH_NEW\""
        if [ ! -z "`grep "$FX_LINE_OLD" "$INI"`" ] \
         && ( [ ! -d "$FX_PATH_OLD" ] || [ -z "`ls -A "$FX_PATH_OLD"`" ] ); then
            echo "fix config: fix path to studiopalette"
            cat "$INI" \
              | sed "s|$FX_LINE_OLD|$FX_LINE_NEW|g" \
              > "$INI.out"
            cp "$INI.out" "$INI"
            rm -f "$INI.out"
        fi

        # fix path to fxs
        FX_PATH_OLD="$CONFIG_DIR/stuff/projects/fxs"
        FX_PATH_NEW="$CONFIG_DIR/stuff/fxs"
        FX_LINE_OLD="TOONZFXPRESETS=\"$FX_PATH_OLD\""
        FX_LINE_NEW="TOONZFXPRESETS=\"$FX_PATH_NEW\""
        if [ ! -z "`grep "$FX_LINE_OLD" "$INI"`" ] \
         && ( [ ! -d "$FX_PATH_OLD" ] || [ -z "`ls -A "$FX_PATH_OLD"`" ] ); then
            echo "fix config: fix path to fxs" 
            cat "$INI" \
              | sed "s|$FX_LINE_OLD|$FX_LINE_NEW|g" \
              > "$INI.out"
            cp "$INI.out" "$INI"
            rm -f "$INI.out"
        fi

        # fix path to library
        LIBRARY_PATH_OLD="$CONFIG_DIR/stuff/projects/library"
        LIBRARY_PATH_NEW="$CONFIG_DIR/stuff/library"
        LIBRARY_LINE_OLD="TOONZLIBRARY=\"$LIBRARY_PATH_OLD\""
        LIBRARY_LINE_NEW="TOONZLIBRARY=\"$LIBRARY_PATH_NEW\""
        if [ ! -z "`grep "$LIBRARY_LINE_OLD" "$INI"`" ] \
         && ( [ ! -d "$LIBRARY_PATH_OLD" ] || [ -z "`ls -A "$LIBRARY_PATH_OLD"`" ] ); then
            echo "fix config: fix path to library" 
            cat "$INI" \
              | sed "s|$LIBRARY_LINE_OLD|$LIBRARY_LINE_NEW|g" \
              > "$INI.out"
            cp "$INI.out" "$INI"
            rm -f "$INI.out"
        fi
    fi

    # update library
    echo "update stuff" 
    mkdir -p "$CONFIG_DIR/stuff/config"
    mkdir -p "$CONFIG_DIR/stuff/profiles"
    cp -ur "$BASE_DIR/share/opentoonz/stuff/library" "$CONFIG_DIR/stuff/" 
    cp -ur "$BASE_DIR/share/opentoonz/stuff/config/qss" "$CONFIG_DIR/stuff/config/" 
    cp -ur "$BASE_DIR/share/opentoonz/stuff/config/loc" "$CONFIG_DIR/stuff/config/" 
    cp -ur "$BASE_DIR/share/opentoonz/stuff/profiles/layouts" "$CONFIG_DIR/stuff/profiles/" 
    cp -ur "$BASE_DIR/share/opentoonz/stuff/config/current.txt" "$CONFIG_DIR/stuff/config/" 
fi

cd "$BASE_DIR/bin"
./OpenToonz "$@"
