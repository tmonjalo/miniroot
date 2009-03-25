#! /bin/sh -e

# get or compute the directory name of the sources

strip_str() {
	echo $1 | sed 's,^[ \t]*,,' | sed 's,[ \t]*$,,'
}

TOP_DIR=$(strip_str $1) # destination parent directory
SRC=$(strip_str $2) # can be a VCS URL, a directory or a tarball
DEST_DIR=$(strip_str $3) # force directory where to checkout or to untar

if [ -n "$(echo $DEST_DIR | tr -d '[:space:]')" ] ; then
	echo $DEST_DIR
else
	if echo $SRC | fgrep -q '://' ; then
		# SRC is an URL
		printf $TOP_DIR/
		echo $SRC | sed 's,://,_,g' | tr '/' '_'
	elif [ -d $SRC/.git ] ; then
		# SRC is a local git repository
		echo $TOP_DIR/local_git_$(basename $SRC)
	elif [ -d $SRC/.hg ] ; then
		# SRC is a local mercurial repository
		echo $TOP_DIR/local_hg_$(basename $SRC)
	elif [ -d "$SRC" ] ; then
		# SRC is a directory
		echo $SRC
	elif [ -f "$SRC" ] ; then
		# SRC is a file, assume it is a tarball
		printf $TOP_DIR/
		tar tf "$SRC" 2>/dev/null | head -n1 | sed 's:/*$::'
	else
		# SRC is unknown
		echo $TOP_DIR/$SRC
	fi
fi
