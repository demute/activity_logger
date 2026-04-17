#!/bin/sh
cd $(dirname ${BASH_SOURCE[0]})

LIMIT=120
MINUTES="$(./ytdis.sh)"

if [ "$MINUTES" -gt "$LIMIT" ]; then
    /sbin/pfctl -a timelimit -f /etc/pf.anchors/timelimit 2> /dev/null
else
    /sbin/pfctl -a timelimit -f /dev/null 2> /dev/null
fi
