#! /bin/sh -e

# get or compute the directory name of the sources

DIR=$1 # destination parent directory
SRC=$2 # can be a VCS URL, a directory or a tarball

if echo $SRC | fgrep -q '://' ; then
	# SRC is an URL
	printf $DIR/
	echo $SRC | sed 's,://,_,g' | tr '/' '_'
elif [ -d "$SRC" ] ; then
	# SRC is a directory
	echo $SRC
elif [ -f "$SRC" ] ; then
	# SRC is a file, assume it is a tarball
	printf $DIR/
	tar tf "$SRC" 2>/dev/null | head -n1 | sed 's:/*$::'
else
	# SRC is unknown
	echo $DIR/$SRC
fi
