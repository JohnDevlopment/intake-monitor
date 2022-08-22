#!/bin/sh

# USAGE: install.sh debug|release<release>

releasetype="$1"

# Missing arg
if [ -z "$releasetype" ]; then
    echo "Missing release type" >&2
    exit 1
fi

installprefix=/usr/local
filename=intake-monitor
if [ "$releasetype" = "debug" ]; then
    filesuffix=-debug
fi

cp -fv bin/linux/intake-monitor.x86_64 $installprefix/bin/$filename$filesuffix
