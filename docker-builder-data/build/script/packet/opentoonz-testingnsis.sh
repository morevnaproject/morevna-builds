source "$PACKET_SCRIPT_DIR/opentoonz-nsis.sh"

DEPS=`echo "$DEPS" | sed "s|opentoonz-master|opentoonz-testing|g"`
