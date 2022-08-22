#!/bin/bash

echo "# Changelog"
echo

declare -r USER=JohnDevlopment
declare -r PROJECT=intake-monitor

git log ${1:?provide revision range} \
    --pretty=format:"* [view commit](https://github.com/$USER/$PROJECT/commit/%H)&bull; %s " \
    --reverse
