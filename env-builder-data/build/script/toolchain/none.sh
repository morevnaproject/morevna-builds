#!/bin/bash

vars_clear "TC_"

# set vars which used explicitly in function manager.sh:set_environment_vars()

export TC_HOST="" #x86_64-linux-gnu
export CROSS_TRIPLE="x86_64-linux-gnu"

export CROSS_ROOT="/usr/${CROSS_TRIPLE}"

export TC_PATH="$CROSS_ROOT/bin:$INITIAL_PATH"
export TC_LD_LIBRARY_PATH="$CROSS_ROOT/lib:/usr/local/lib:/usr/local/lib64:$INITIAL_LD_LIBRARY_PATH"

export TC_LDFLAGS=" -L$CROSS_ROOT/lib $INITIAL_LDFLAGS"
export TC_PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig/:/usr/share/pkgconfig/"



