.PHONY : check_latest

check_latest : linux_check_latest busybox_check_latest \
	zlib_check_latest dropbear_check_latest \
	e2fsprogs_check_latest mdadm_check_latest \
	libroxml_check_latest
