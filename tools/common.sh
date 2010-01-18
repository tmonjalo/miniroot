# regular expressions for file extensions
TAR_LONG_EXT='tar\($\|\.[^.]*$\)'
TAR_SHORT_EXT='\(tgz\|tbz2\|txz\)$'
TARBALL_EXT="\($TAR_LONG_EXT\|$TAR_SHORT_EXT\)"
ARCHIVE_EXT="\($TAR_LONG_EXT\|$TAR_SHORT_EXT\)"

# extension detection
is_tarball () {
	echo $1 | grep -q "\.$TARBALL_EXT"
}

# strip functions: remove spaces at left or right
left_strip () {
	sed 's,^[ \t]*,,'
}
right_strip () {
	sed 's,[ \t]*$,,'
}
strip_str () {
	echo $1 | left_strip | right_strip
}
