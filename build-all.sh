#!/bin/bash

BASE_DIR=$(cd `dirname "$0"`; pwd)

"$BASE_DIR/build-opentoonz.sh"
"$BASE_DIR/build-synfigstudio-linux.sh"
