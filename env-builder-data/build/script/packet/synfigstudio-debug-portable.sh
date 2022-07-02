source "$PACKET_SCRIPT_DIR/synfigstudio-master-portable.sh"
DEPS=`echo "$DEPS" | sed "s|synfigstudio-master|synfigstudio-debug|g"`
