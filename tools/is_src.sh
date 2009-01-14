#! /bin/sh -e

# check if the parameters specify valid sources

DIR=$1
SRC=$2 # SRC can be a VCS URL, a directory or a tarball

if [ -e "$DIR/$SRC" ] || echo "$SRC" | fgrep -q '://' ; then
	echo true
else
	echo false
fi
