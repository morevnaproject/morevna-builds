source "$PACKET_SCRIPT_DIR/opentoonz-master-appimage.sh"

DEPS=`echo "$DEPS" | sed "s|opentoonz-master|opentoonz-me|g"`
