#! /bin/sh -e

# get sources by download, checkout or tarball
# and patch them

strip_str() {
	echo $* | sed 's,^[ \t]*,,' | sed 's,[ \t]*$,,'
}

TOP_DIR=$(strip_str $1) # destination parent directory
SRC=$(strip_str $2) # can be a VCS URL to checkout, a tarball URL to download, a directory or a tarball
SRC_DIR=$(strip_str $3) # directory where to checkout or to untar
PATCH_DIR=$(strip_str $4) # directory of patch files to apply

SCRIPTS_DIR=$(dirname $0)
URL="$(echo $SRC | cut -d' ' -f1)" # replace SRC in VCS case with branch option
BRANCH="$(echo $SRC | cut -d' ' -sf2)" # SRC can have a branch option in VCS case
ERROR_DIR=/tmp/miniroot_error # fake directory in case of error

vcs_checkout () { # <vcs tool> <main command> [branch command]
	local TOOL=$1
	local MAIN_COMMAND=$2
	local BRANCH_COMMAND=$3
	echo "$TOOL $MAIN_COMMAND $URL $SRC_DIR"
	$TOOL $MAIN_COMMAND "$URL" "$SRC_DIR"
	if [ -n "$BRANCH" ] ; then
		if [ -z "$BRANCH_COMMAND" ] ; then
			echo $TOOL: no branch support for $BRANCH
			exit 1
		fi
		# branch can be <remote_repository>/<branch>
		if [ $TOOL = git ] ; then
			if GIT_DIR="$SRC_DIR/.git" git branch -r | grep -q " $BRANCH$" ; then
				# create a local branch if it is a remote one
				local LOCAL_BRANCH=$(echo $BRANCH | sed -n 's,[^/]*/\(.*\),\1,p')
				BRANCH_COMMAND="$BRANCH_COMMAND -b $LOCAL_BRANCH"
			fi
		fi
		echo "$TOOL $BRANCH_COMMAND $BRANCH"
		( cd "$SRC_DIR" ; $TOOL $BRANCH_COMMAND "$BRANCH" ) || exit $?
	fi
}

extract_tarball () { # <tarball>
	local TARBALL=$*
	local TARBALL_DIR=$(tar tf "$TARBALL" 2>/dev/null | head -n1 | sed 's,/.*$,,')
	echo untar sources to $SRC_DIR
	(tar x -C "$TOP_DIR" -f "$TARBALL" --checkpoint --checkpoint-action exec='printf .' 2>/dev/null && echo) ||
	# the option checkpoint-action is not always supported (still recent)
	tar x -C "$TOP_DIR" -f "$TARBALL"
	if [ "$(readlink -nm $TOP_DIR/$TARBALL_DIR)" != "$(readlink -nm $SRC_DIR)" ] ; then
		# move to specified directory
		mkdir -p $(dirname $SRC_DIR)
		mv $TOP_DIR/$TARBALL_DIR $SRC_DIR
	fi
}

# check the source directory
if echo $SRC_DIR | grep -q "^$ERROR_DIR" ; then
	echo "bad source: $SRC"
	exit 1
fi
if [ -d "$SRC_DIR" ] ; then
	# already checked out or extracted
	exit 0
fi

# copy, extract or download
if echo $SRC | fgrep -q '://' ; then
	# SRC is an URL (can have a branch option)
	PROTOCOL=$($SCRIPTS_DIR/get_protocol_from_url.sh $URL)
	if echo $PROTOCOL | grep -q tp ; then # http, ftp
		TARBALL="$TOP_DIR/$(basename $SRC)"
		if [ ! -s "$TARBALL" ] ; then
			echo "wget $SRC"
			( set -e
				cd "$TOP_DIR"
				wget "$SRC"
			) || exit $?
		fi
		extract_tarball $TARBALL
	elif [ "$PROTOCOL" = git ] ; then
		vcs_checkout git clone checkout
	elif [ "$PROTOCOL" = hg ] ; then
		vcs_checkout hg clone
	elif [ "$PROTOCOL" = svn ] ; then
		vcs_checkout svn checkout
	else
		echo $PROTOCOL: protocol not supported
		exit 1
	fi
elif [ -d "$SRC/.git" ] ; then
	# SRC is a local git repository (space enabled in the path)
	URL="$SRC"
	unset BRANCH
	vcs_checkout git clone checkout
elif [ -d "$URL/.git" ] ; then
	# SRC is a local git repository (without space in the path) with a specified branch
	vcs_checkout git clone checkout
elif [ -d "$SRC/.hg" ] ; then
	# SRC is a local mercurial repository (space enabled in the path)
	URL="$SRC"
	unset BRANCH
	vcs_checkout hg clone
elif [ -d "$URL/.hg" ] ; then
	# SRC is a local mercurial repository (without space in the path) with a specified branch
	vcs_checkout hg clone
elif [ -d "$SRC" ] ; then
	# SRC is a directory
	mkdir -p "$SRC_DIR"
	tar --create --exclude-vcs --directory "$SRC" . | tar --extract --directory "$SRC_DIR"
else
	# SRC is a file, assume it is a tarball
	extract_tarball $SRC
fi

# patch
if [ -n "$PATCH_DIR" ] ; then
	echo patch sources
	make -s $SCRIPTS_DIR/patch-kernel.sh
	$SCRIPTS_DIR/patch-kernel.sh $SRC_DIR $PATCH_DIR
fi
