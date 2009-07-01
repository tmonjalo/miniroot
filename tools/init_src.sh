#! /bin/sh -e

# get sources by download, checkout or tarball
# and patch them

strip_str() {
	echo $* | sed 's,^[ \t]*,,' | sed 's,[ \t]*$,,'
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

vcs_checkout () { # <vcs tool> <main command> [branch command] <URL [branch]> <directory>
	local vcs_TOOL=$1
	local vcs_MAIN_COMMAND=$2
	local vcs_BRANCH_COMMAND=$3
	local vcs_SRC="$4"
	local vcs_DIR="$5"
	local vcs_URL="$(echo $vcs_SRC | sed 's,\([^ ]*\).*,\1,')"
	local vcs_BRANCH="$(echo $vcs_SRC | sed 's,[^ ]* *\(.*\),\1,')"
	$vcs_TOOL $vcs_MAIN_COMMAND "$vcs_URL" "$vcs_DIR"
	if [ -n "$vcs_BRANCH" ] ; then
		if [ -z "$vcs_BRANCH_COMMAND" ] ; then
			echo $vcs_TOOL: no branch support for $vcs_BRANCH
			exit 1
		fi
		( cd "$vcs_DIR" ; $vcs_TOOL $vcs_BRANCH_COMMAND "$vcs_BRANCH" )
	fi
}

# copy, extract or download
if echo $SRC | fgrep -q '://' ; then
	# SRC is an URL
	check_src_dir
	VCS=$($SCRIPTS_DIR/get_vcs_from_url.sh $SRC)
	if [ "$VCS" = git ] ; then
		vcs_checkout git clone checkout "$SRC" "$DEST_DIR"
	elif [ "$VCS" = hg ] ; then
		vcs_checkout hg clone '' "$SRC" "$DEST_DIR"
	elif [ "$VCS" = svn ] ; then
		vcs_checkout svn checkout '' "$SRC" "$DEST_DIR"
	else
		echo $VCS: unknown protocol
		exit 1
	fi
elif [ -d $SRC/.git ] ; then
	# checkout a local git repository
	check_src_dir
	vcs_checkout git clone checkout "$SRC" "$DEST_DIR"
elif [ -d $SRC/.hg ] ; then
	# checkout a local mercurial repository
	check_src_dir
	vcs_checkout hg clone '' "$SRC" "$DEST_DIR"
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
fi

# patch
if [ -n "$PATCH_DIR" ] ; then
	make -s $SCRIPTS_DIR/patch-kernel.sh
	$SCRIPTS_DIR/patch-kernel.sh $DEST_DIR $PATCH_DIR
fi
