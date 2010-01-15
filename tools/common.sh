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
