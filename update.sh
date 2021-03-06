#!/usr/bin/env bash

# Which top-level folders should be included in the update?
# Visit https://cdm.media.ccc.de/ to see the folders
folders=(blinkenlights broadcast congress contributors events)

# Join multiple values together
# https://stackoverflow.com/a/17841619
function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

# Form a pattern to only filter files in wanted folders
pattern="^\./\\($(join_by "\\|" "${folders[@]}")\\)"

tempfile="$(mktemp)"
tempfile2="$(mktemp)"
tempfile3="$(mktemp)"
trap 'rm -rf "$tempfile" "$tempfile2" "$tempfile3"' EXIT

# wget: Download index file
# gunzip: Unzip the compressed file
# cut: Remove the first two columns (timestamp and file size)
# grep: Only used files in wanted folders
wget --output-document=- --quiet https://cdn.media.ccc.de/INDEX.gz \
| gunzip \
| cut --delimiter=" " --fields=3- \
| grep "$pattern" \
| sort \
> "$tempfile"

find | sort > "$tempfile2"

comm -23 "$tempfile" "$tempfile2" > "$tempfile3"

# Add all URLs without space to annex
sed --quiet 's@^\./\(\S\+\)$@https://cdn.media.ccc.de/\1 \1@p' "$tempfile3" | git annex addurl --relaxed --raw --batch --with-files --jobs=cpus
grep '\s' "$tempfile3" | while IFS= read path
do
	if ! [[ -h "$path" || -f "$path" ]]
	then
		git annex addurl --relaxed --raw --file "$path" "https://cdn.media.ccc.de/${path#./}"
	fi
done

git commit --message "Add new files"

