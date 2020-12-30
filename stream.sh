#!/usr/bin/env bash

while (( $# > 0 ))
do
    git annex whereis "$1" | sed --quiet 's/^\s*web: \(.*\)$/\1/p' | xargs smplayer
    git annex metadata --tag watched "$1"
    shift
done

