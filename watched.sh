#!/usr/bin/env bash

git annex find --metadata=tag=watched | sed 's@/[^/]\+/\([^/]\+_\)[^_]\+$@:\1@' | sort | uniq | while IFS=: read base file
do
    comm -13 <(git annex find "$base" --metadata=tag=watched --include="*/$file*" | sort) <(find "$base" -name "${file}*" | sort) | xargs git annex metadata --tag watched 2>/dev/null || true
done

