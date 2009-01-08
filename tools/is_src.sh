#! /bin/sh -e

if [ -e "$1" ] || echo "$1" | fgrep -q '://' ; then
	echo true
else
	echo false
fi
