#!/bin/bash

set -e

BASE_DIR=$(cd `dirname "$0"`; pwd)

"$BASE_DIR/build-synfigstudio.sh"
#"$BASE_DIR/build-synfigstudio-debug.sh"
#"$BASE_DIR/build-opentoonz.sh"
"$BASE_DIR/build-opentoonz-me.sh"
#"$BASE_DIR/build-papagayong.sh"
