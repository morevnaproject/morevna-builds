source "$PACKET_SCRIPT_DIR/opentoonz-portable.sh"

DEPS=`echo "$DEPS" | sed "s|opentoonz-master|opentoonz-testing|g"`
