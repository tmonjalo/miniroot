#! /bin/sh -e

# get sources by download, checkout or tarball
# and patch them

strip_str() {
	echo $1 | sed 's,^[ \t]*,,' | sed 's,[ \t]*$,,'
}

SCRIPTS_DIR=$(dirname $0)
TOP_DIR=$(strip_str $1) # destination parent directory
SRC=$(strip_str $2) # can be a VCS URL to checkout, a directory or a tarball
URL=$(strip_str $3) # can be a tarball URL or nothing
PATCH_DIR=$(strip_str $4) # directory of patch files to apply
DEST_DIR=$(strip_str $5) # force directory where to checkout or to untar

check_src_dir () {
	if [ -d "$DEST_DIR" ] ; then
		exit 0 # already checked out or extracted
	fi
	SRC_DIR=$($SCRIPTS_DIR/get_src_dir.sh "$TOP_DIR" "$SRC")
	if [ "$SRC_DIR" = "$TOP_DIR/" ] ; then
		echo "bad source: $SRC"
		exit 1
	fi
	DEST_DIR=${DEST_DIR:-$SRC_DIR}
	if [ -d "$DEST_DIR" ] ; then
		exit 0 # already checked out or extracted
	fi
}

patch_src_dir () {
	if [ -n "$PATCH_DIR" ] ; then
		make -s $SCRIPTS_DIR/patch-kernel.sh
		$SCRIPTS_DIR/patch-kernel.sh $DEST_DIR $PATCH_DIR
	fi
}

if echo $SRC | fgrep -q '://' ; then
	# SRC is an URL
	check_src_dir
	URL=$SRC
	VCS=$($SCRIPTS_DIR/get_vcs_from_url.sh $URL)
	if [ "$VCS" = git ] ; then
		git clone "$URL" "$DEST_DIR"
	elif [ "$VCS" = hg ] ; then
		hg clone "$URL" "$DEST_DIR"
	elif [ "$VCS" = svn ] ; then
		svn co "$URL" "$DEST_DIR"
	else
		echo $VCS: unknown protocol
		exit 1
	fi
	patch_src_dir
elif [ -d $SRC/.git ] ; then
	# checkout a local git repository
	check_src_dir
	git clone "$SRC" "$DEST_DIR"
elif [ -d $SRC/.hg ] ; then
	# checkout a local mercurial repository
	check_src_dir
	hg clone "$SRC" "$DEST_DIR"
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
	echo untar sources to $DEST_DIR
	tar x -C "$TOP_DIR" -f "$SRC"
	if [ "$SRC_DIR" != "$DEST_DIR" ] ; then
		mv $SRC_DIR $DEST_DIR
	fi
	patch_src_dir
fi
