#! /bin/sh -e

# get or compute the directory name of the sources

strip_str() {
	echo $1 | sed 's,^[ \t]*,,' | sed 's,[ \t]*$,,'
}

TOP_DIR=$(strip_str $1) # destination parent directory
SRC=$(strip_str $2) # can be a VCS URL, a directory or a tarball

SCRIPTS_DIR=$(dirname $0)
VCS_SRC="$(echo $SRC | cut -d' ' -f1)" # replace SRC in VCS case with branch option
ERROR_DIR=/tmp/miniroot_error/$SRC # return a fake directory in case of error

if echo $SRC | fgrep -q '://' ; then
	# SRC is an URL (can have a branch option)
	printf $TOP_DIR/
	if $SCRIPTS_DIR/get_protocol_from_url.sh $VCS_SRC | grep -q tp ; then # http, ftp
		# tarball, get a simple directory name
		basename $SRC | sed 's,\.tar\.[^-.]*,,'
	else
		# VCS, compute a directory name
		echo $SRC | cut -d' ' -f1 | sed 's,://,_,g' | tr '/' '_'
	fi
elif [ -d "$SRC/.git" ] ; then
	# SRC is a local git repository (space enabled in the path)
	echo $TOP_DIR/local_git_$(basename $SRC)
elif [ -d "$VCS_SRC/.git" ] ; then
	# SRC is a local git repository (without space in the path) with a specified branch
	echo $TOP_DIR/local_git_$(basename $VCS_SRC)
elif [ -d "$SRC/.hg" ] ; then
	# SRC is a local mercurial repository (space enabled in the path)
	echo $TOP_DIR/local_hg_$(basename $SRC)
elif [ -d "$VCS_SRC/.hg" ] ; then
	# SRC is a local mercurial repository (without space in the path) with a specified branch
	echo $TOP_DIR/local_hg_$(basename $VCS_SRC)
elif [ -d "$SRC" ] ; then
	# SRC is a directory
	echo $SRC
elif [ -f "$SRC" ] ; then
	# SRC is a file, assume it is a tarball
	TAR_DIR=$(tar tf "$SRC" 2>/dev/null | head -n1 | sed 's,/*$,,')
	if [ -z "$TAR_DIR" ] ; then
		echo $ERROR_DIR
	else
		echo $TOP_DIR/$TAR_DIR
	fi
else
	# SRC is unknown
	echo $ERROR_DIR
fi
