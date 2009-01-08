#! /bin/sh -e

DIR=$1
SRC=$2 # SRC can be a VCS URL, a directory or a tarball

printf $DIR/
if echo $SRC | fgrep -q '://' ; then
	# SRC is an URL
	echo $SRC | sed 's,://,_,g' | tr '/' '_'
elif [ -d "$DIR/$SRC" ] ; then
	# SRC is a directory
	echo $SRC
elif [ -f "$DIR/$SRC" ] ; then
	# SRC is a file, assume it is a tarball
	tar tf "$DIR/$SRC" 2>/dev/null | head -n1 | sed 's:/*$::'
else
	# SRC is unknown
	echo $SRC
fi
