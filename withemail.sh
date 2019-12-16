#!/bin/bash

set -e
set -o pipefail

# accepts environment vars
# EMAIL_SUCCESS
# EMAIL_FAILED
# EMAIL_QUIET
# EMAIL_SUBJECT
# EMAIL_BODY


if [ ! -z "$EMAIL_QUIET" ]; then
    # report only errors
    EMAIL_SUCCESS=
fi

if [ -z "$EMAIL_SUBJECT" ]; then
    EMAIL_SUBJECT="builder task finished"
fi

COMMAND="$@"
LOG_FILE="/tmp/withemail-`uuidgen`.log"
touch "$LOG_FILE"


send_email() {
    local EMAIL="$1"
    local MESSAGE="$2"

    echo "$MESSAGE"

    if [ ! -z "$EMAIL" ]; then
        mutt -s "$EMAIL_SUBJECT - $MESSAGE" -a "$LOG_FILE" -- "$EMAIL" << EOF
$EMAIL_BODY

Command:
    $COMMAND

$MESSAGE
EOF
        echo "email sent to $EMAIL"
    fi
    rm "$LOG_FILE"
}


("$@" 2>&1 | tee "$LOG_FILE") || (send_email "$EMAIL_FAILED" "FAILED" && false)

send_email "$EMAIL_SUCCESS" "SUCCESS"
