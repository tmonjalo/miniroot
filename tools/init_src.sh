#! /bin/sh -e

# get sources by download, checkout or archive
# and patch them

SCRIPTS_DIR=$(dirname $0)
. $SCRIPTS_DIR/common.sh

# arguments
SRC=$(strip_str $1) # can be a VCS URL to checkout, an URL of archive to download, a directory or an archive
DL_DIR=$(strip_str $2) # directory where download an archive
SRC_DIR=$(strip_str $3) # directory where to checkout or to untar
PATCH_DIR=$(strip_str $4) # directory of patch files to apply

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
			echo "$TOOL: no branch support for $BRANCH"
			exit 1
		fi
		# branch can be <remote_repository>/<branch>
		if [ $TOOL = git ] ; then
			if git --git-dir="$SRC_DIR/.git" branch -r | grep -q " $BRANCH$" ; then
				# create a local branch if it is a remote one
				local LOCAL_BRANCH=$(echo $BRANCH | sed -n 's,[^/]*/\(.*\),\1,p')
				BRANCH_COMMAND="$BRANCH_COMMAND -b $LOCAL_BRANCH"
			fi
		fi
		echo "$TOOL $BRANCH_COMMAND $BRANCH"
		( cd "$SRC_DIR" && $TOOL $BRANCH_COMMAND "$BRANCH" ) || exit $?
	fi
}

extract_tarball () { # <tarball>
	echo "untar sources to $SRC_DIR"
	local TARBALL=$*
	local EXTRACT_DIR=$(dirname "$SRC_DIR")
	local CONTAINER_DIR="$(tar tf "$TARBALL" 2>&- | sed "s,^\([^/]*\).*,$EXTRACT_DIR/\1," | uniq)"
	# check if all the files are contained in a single root directory
	if [ "$(echo "$CONTAINER_DIR" | wc -l)" -gt 1 ] ; then
		EXTRACT_DIR="$SRC_DIR"
		mkdir -p $EXTRACT_DIR
		CONTAINER_DIR="$SRC_DIR"
	# check if a directory with the same name already exists
	elif [ -e "$CONTAINER_DIR" ] ; then
		echo "$CONTAINER_DIR already exists"
		exit 1
	fi
	# extract
	(tar x -C "$EXTRACT_DIR" -f "$TARBALL" --checkpoint --checkpoint-action exec='printf .' 2>&- && echo .) ||
	# the option checkpoint-action is not always supported (still recent)
	tar x -C "$EXTRACT_DIR" -f "$TARBALL"
	# move if not in the expected directory
	mv_src_dir "$CONTAINER_DIR" "$SRC_DIR"
}

extract_zip () { # <zip archive>
	echo "unzip sources to $SRC_DIR"
	local ZIP=$*
	local EXTRACT_DIR=$(dirname "$SRC_DIR")
	local CONTAINER_DIR="$(unzip -l "$ZIP" | sed -n "s,^ *[0-9]\+ \+[-0-9]\+ \+[:0-9]\+ \+\([^/]*\).*,$EXTRACT_DIR/\1,p" | uniq)"
	# check if all the files are contained in a single root directory
	if [ "$(echo "$CONTAINER_DIR" | wc -l)" -gt 1 ] ; then
		EXTRACT_DIR="$SRC_DIR"
		CONTAINER_DIR="$SRC_DIR"
	# check if a directory with the same name already exists
	elif [ -e "$CONTAINER_DIR" ] ; then
		echo "$CONTAINER_DIR already exists"
		exit 1
	fi
	# extract
	unzip -qo "$ZIP" -d "$EXTRACT_DIR"
	# move if not in the expected directory
	mv_src_dir "$CONTAINER_DIR" "$SRC_DIR"
}

# identify archive type and extract
extract_archive () { # <archive>
	local ARCHIVE=$*
	case "$ARCHIVE" in
		*.zip)
			extract_zip $ARCHIVE
		;;
		*) # tarball fallback
			extract_tarball $ARCHIVE
		;;
	esac
}

# move if src and dst are different
mv_src_dir () { # <src> <dst>
	if [ "$(readlink -nm "$1")" != "$(readlink -nm "$2")" ] ; then
		mkdir -p $(dirname "$2")
		mv "$1" "$2"
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
		ARCHIVE="$DL_DIR/$(basename $SRC)"
		if [ ! -s "$ARCHIVE" ] ; then
			echo "wget $SRC"
			mkdir -p "$DL_DIR"
			( cd "$DL_DIR" && wget "$SRC" ) || exit $?
		fi
		extract_archive $ARCHIVE
	elif [ "$PROTOCOL" = git ] ; then
		vcs_checkout git clone checkout
	elif [ "$PROTOCOL" = hg ] ; then
		vcs_checkout hg clone
	elif [ "$PROTOCOL" = svn ] ; then
		vcs_checkout svn checkout
	else
		echo "$PROTOCOL: protocol not supported"
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
	# SRC is a file, assume it is an archive
	extract_archive $SRC
fi

# patch
if [ -n "$PATCH_DIR" ] ; then
	echo 'patch sources'
	if [ -d "$SRC_DIR/.git" ] && find $PATCH_DIR -type f | head -n1 | xargs -r head -n1 | grep -q '^From ' ; then
		# apply patches as git commits
		# git-am doesn't work with --work-tree ?
		#git --git-dir="$SRC_DIR/.git" --work-tree="$SRC_DIR" am "$PATCH_DIR/*"
		PATCH_ABSDIR=$(readlink -nm "$PATCH_DIR")
		( cd "$SRC_DIR" && git am "$PATCH_ABSDIR"/* ) || exit $?
	else
		make -s $SCRIPTS_DIR/patch-kernel.sh
		$SCRIPTS_DIR/patch-kernel.sh "$SRC_DIR" "$PATCH_DIR"
	fi
fi
