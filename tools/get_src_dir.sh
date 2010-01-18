#! /bin/sh -e

# get or compute the directory name of the sources

SCRIPTS_DIR=$(dirname $0)
. $SCRIPTS_DIR/common.sh

# arguments
TOP_DIR=$(echo $1 | right_strip) # destination parent directory
SRC=$2 # can be a VCS URL, a directory or an archive

# first, for optimization, test the most frequent case: an archive
ARCHIVE=$(echo $SRC | sed -n "s,.*/,,;s,\(.*\)\.$ARCHIVE_EXT,\1,p")
if [ -n "$ARCHIVE" ] ; then
	# SRC is an archive (URL or file)
	echo $TOP_DIR/$ARCHIVE
	exit
fi

SRC=$(strip_str $2)
ERROR_DIR=/tmp/miniroot_error/$SRC # return a fake directory in case of error
VCS_SRC="$(echo $SRC | cut -d' ' -f1)" # replace SRC in VCS case with branch option

if echo $SRC | fgrep -q '://' ; then
	# SRC is a VCS URL (can have a branch option)
	printf $TOP_DIR/
	echo $SRC | cut -d' ' -f1 | sed 's,://,_,g' | tr '/' '_'
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
else
	# SRC is unknown
	echo $ERROR_DIR
fi
