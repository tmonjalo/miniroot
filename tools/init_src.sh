#! /bin/sh -e

# get sources by download, checkout or tarball
# and patch them

DIR=$1
SRC=$2 # SRC can be a VCS URL to checkout, a directory or a tarball
URL=$3 # URL can be a tarball URL or nothing
PATCH_DIR=$4

check_src_dir () {
	SRC_DIR=$($(dirname $0)/get_src_dir.sh "$DIR" "$SRC")
	if [ -d "$SRC_DIR" ] ; then
		exit 0
	fi
}

patch_src_dir () {
	if [ -n "$PATCH_DIR" ] ; then
		$(dirname $0)/patch-kernel.sh $SRC_DIR $PATCH_DIR
	fi
}

if echo $SRC | fgrep -q '://' ; then
	# SRC is an URL
	check_src_dir
	URL=$SRC
	VCS=$($(dirname $0)/get_vcs_from_url.sh $URL)
	if [ "$VCS" = "git" ] ; then
		git clone "$URL" "$SRC_DIR" # could be $DIR/$(basename $URL)
	elif [ "$VCS" = "svn" ] ; then
		svn co "$URL" "$SRC_DIR" # could be $DIR/$(basename $URL)
	else
		echo $VCS: unknown protocol
		exit 1
	fi
	patch_src_dir
elif [ -d "$DIR/$SRC" ] ; then
	# SRC is an existing directory
	exit 0
else
	# SRC is a file, assume it is a tarball
	if [ ! -f "$DIR/$SRC" ] || ! tar tf "$DIR/$SRC" | head -n1 >/dev/null 2>&1 ; then
		wget -O "$DIR/$SRC" "$URL"
	fi
	check_src_dir
	echo untar sources to $DIR
	tar x -C "$DIR" -f "$DIR/$SRC"
	patch_src_dir
fi
