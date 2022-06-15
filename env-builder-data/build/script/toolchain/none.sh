#!/bin/bash

vars_clear "TC_"

# set vars which used explicitly in function manager.sh:set_environment_vars()

export TC_HOST=""

if [[ $NATIVE_ARCH == 32 ]]; then
    export CROSS_TRIPLE="i386-linux-gnu"
else
    export CROSS_TRIPLE="x86_64-linux-gnu"
fi

export CROSS_ROOT="/usr/${CROSS_TRIPLE}"

export TC_PATH="$CROSS_ROOT/bin:$INITIAL_PATH"
export TC_LD_LIBRARY_PATH="/usr/local/lib:/usr/local/lib64:/usr/lib/x86_64-linux-gnu/:/usr/lib/:$INITIAL_LD_LIBRARY_PATH"

export TC_LDFLAGS=" -L/usr/local/lib $INITIAL_LDFLAGS"
export TC_PKG_CONFIG_PATH="/usr/lib/${CROSS_TRIPLE}/pkgconfig/:/usr/share/pkgconfig/"



