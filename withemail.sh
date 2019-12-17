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


print_email() {
    local MESSAGE="$1"
    echo "$EMAIL_BODY"
    echo
    echo "Command:"
    echo "    $COMMAND"
    echo "$MESSAGE"
    echo
    echo "log:"
    echo "----------------------------------------"
    tail -n 100 "$LOG_FILE"
    echo "----------------------------------------"
    echo
}

send_email() {
    local EMAIL="$1"
    local MESSAGE="$2"
    echo "$MESSAGE"
    if [ ! -z "$EMAIL" ]; then
        print_email "$MESSAGE" | mutt -s "$EMAIL_SUBJECT - $MESSAGE" "$EMAIL"
        #print_email "$MESSAGE" | mutt -s "$EMAIL_SUBJECT - $MESSAGE" -a "$LOG_FILE" -- "$EMAIL"
        echo "email sent to $EMAIL"
    fi
    rm "$LOG_FILE"
}


("$@" 2>&1 | tee "$LOG_FILE") || (send_email "$EMAIL_FAILED" "FAILED" && false)

send_email "$EMAIL_SUCCESS" "SUCCESS"
