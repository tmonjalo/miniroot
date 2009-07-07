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
VCS_URL="$(echo $SRC | cut -d' ' -f1)" # replace SRC in VCS case with branch option
VCS_BRANCH="$(echo $SRC | cut -d' ' -sf2)" # SRC can have a branch option in VCS case

check_src_dir () {
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

vcs_checkout () { # <vcs tool> <main command> [branch command]
	local VCS_TOOL=$1
	local VCS_MAIN_COMMAND=$2
	local VCS_BRANCH_COMMAND=$3
	echo "$VCS_TOOL $VCS_MAIN_COMMAND $VCS_URL $DEST_DIR"
	$VCS_TOOL $VCS_MAIN_COMMAND "$VCS_URL" "$DEST_DIR"
	if [ -n "$VCS_BRANCH" ] ; then
		if [ -z "$VCS_BRANCH_COMMAND" ] ; then
			echo $VCS_TOOL: no branch support for $VCS_BRANCH
			exit 1
		fi
		# branch can be <remote_repository>/<branch>
		local VCS_LOCAL_BRANCH=$(echo $VCS_BRANCH | sed -n 's,.\+/\(.*\),\1,p')
		if [ -n "$VCS_LOCAL_BRANCH" -a $VCS_TOOL = git ] ; then
			# create a local branch if it is a remote one
			VCS_BRANCH_COMMAND="$VCS_BRANCH_COMMAND -b $VCS_LOCAL_BRANCH"
		fi
		echo "$VCS_TOOL $VCS_BRANCH_COMMAND $VCS_BRANCH"
		( cd "$DEST_DIR" ; $VCS_TOOL $VCS_BRANCH_COMMAND "$VCS_BRANCH" )
	fi
}

# if the forced directory exists
if [ -d "$DEST_DIR" ] ; then
	exit 0 # already checked out or extracted
fi

# copy, extract or download
if echo $SRC | fgrep -q '://' ; then
	# SRC is an URL
	check_src_dir
	VCS=$($SCRIPTS_DIR/get_vcs_from_url.sh $VCS_URL)
	if [ "$VCS" = git ] ; then
		vcs_checkout git clone checkout
	elif [ "$VCS" = hg ] ; then
		vcs_checkout hg clone
	elif [ "$VCS" = svn ] ; then
		vcs_checkout svn checkout
	else
		echo $VCS: protocol not supported
		exit 1
	fi
elif [ -d "$SRC/.git" ] ; then
	# SRC is a local git repository (space enabled in the path)
	check_src_dir
	VCS_URL="$SRC"
	unset VCS_BRANCH
	vcs_checkout git clone checkout
elif [ -d "$VCS_URL/.git" ] ; then
	# SRC is a local git repository (without space in the path) with a specified branch
	check_src_dir
	vcs_checkout git clone checkout
elif [ -d "$SRC/.hg" ] ; then
	# SRC is a local mercurial repository (space enabled in the path)
	check_src_dir
	VCS_URL="$SRC"
	unset VCS_BRANCH
	vcs_checkout hg clone
elif [ -d "$VCS_URL/.hg" ] ; then
	# SRC is a local mercurial repository (without space in the path) with a specified branch
	check_src_dir
	vcs_checkout hg clone
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
		echo "wget -O $SRC $URL"
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
	echo patch sources
	make -s $SCRIPTS_DIR/patch-kernel.sh
	$SCRIPTS_DIR/patch-kernel.sh $DEST_DIR $PATCH_DIR
fi
