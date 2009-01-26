#! /bin/sh -e

# check if the parameters specify valid sources

SRC=$1 # can be a VCS URL, a directory or a tarball

if [ -e "$SRC" ] || echo "$SRC" | fgrep -q '://' ; then
	echo true
else
	echo false
fi
