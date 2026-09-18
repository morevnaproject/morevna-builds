#!/bin/sh
OPENTOONZ_BASE=$(dirname "$0")

if [ ! -d $HOME/.config/OpenToonz ]; then
    mkdir -p $HOME/.config/OpenToonz
fi

if [ ! -d $HOME/.config/OpenToonz/stuff ]; then
    cp -r $OPENTOONZ_BASE/share/opentoonz/stuff $HOME/.config/OpenToonz
fi

if [ ! -d $HOME/.config/OpenToonz/stuff/projects/library ]; then
    mkdir -p $HOME/.config/OpenToonz/stuff/projects/library
fi

if [ ! -d $HOME/.config/OpenToonz/stuff/projects/fxs ]; then
    mkdir -p $HOME/.config/OpenToonz/stuff/projects/fxs
fi

if [ ! -e $HOME/.config/OpenToonz/SystemVar.ini ]; then
    cat << EOF > $HOME/.config/OpenToonz/SystemVar.ini
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
fi

export PATH="${OPENTOONZ_BASE}/bin:$PATH"
export LD_LIBRARY_PATH="${OPENTOONZ_BASE}/lib/opentoonz:${OPENTOONZ_BASE}/lib:${LD_LIBRARY_PATH}"

exec $OPENTOONZ_BASE/bin/OpenToonz "$@"
