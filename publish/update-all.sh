#!/bin/bash

OLDDIR=`pwd`
BASE_DIR=$(cd `dirname "$0"`; pwd)
cd "$OLDDIR"

"$BASE_DIR/update-opentoonz.sh"
"$BASE_DIR/update-synfigstudio.sh"
