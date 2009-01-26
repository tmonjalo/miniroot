#! /bin/sh -e

# get sources by download, checkout or tarball
# and patch them

SCRIPTS_DIR=$(dirname $0)
DIR=$1 # destination parent directory
SRC=$2 # can be a VCS URL to checkout, a directory or a tarball
URL=$3 # can be a tarball URL or nothing
PATCH_DIR=$4

check_src_dir () {
	SRC_DIR=$($SCRIPTS_DIR/get_src_dir.sh "$DIR" "$SRC")
	if [ "$SRC_DIR" = "$DIR/" ] ; then
		echo "bad source: $DIR/$SRC"
		exit 1
	elif [ -d "$SRC_DIR" ] ; then
		exit 0
	fi
}

patch_src_dir () {
	if [ -n "$PATCH_DIR" ] ; then
		make -s $SCRIPTS_DIR/patch-kernel.sh
		$SCRIPTS_DIR/patch-kernel.sh $SRC_DIR $PATCH_DIR
	fi
}

if echo $SRC | fgrep -q '://' ; then
	# SRC is an URL
	check_src_dir
	URL=$SRC
	VCS=$($SCRIPTS_DIR/get_vcs_from_url.sh $URL)
	if [ "$VCS" = "git" ] ; then
		git clone "$URL" "$SRC_DIR" # could be $DIR/$(basename $URL)
	elif [ "$VCS" = "svn" ] ; then
		svn co "$URL" "$SRC_DIR" # could be $DIR/$(basename $URL)
	else
		echo $VCS: unknown protocol
		exit 1
	fi
	patch_src_dir
elif [ -d "$SRC" ] ; then
	# SRC is an existing directory
	exit 0
else
	# SRC is a file, assume it is a tarball
	if [ ! -s "$SRC" ] ; then
		if [ -z "$URL" ] ; then
			echo "no URL to download"
			exit 1
		fi
		wget -O "$SRC" "$URL"
	fi
	check_src_dir
	echo untar sources to $SRC_DIR
	tar x -C "$DIR" -f "$SRC"
	patch_src_dir
fi
