.PHONY : check_latest

# CHECK_LATEST <package> <PACKAGE> <latest version>
# print default and latest version
define CHECK_LATEST
	echo "default $(strip $1): $(strip $(call GET_DEFAULT_VERSION, $1, $2))"
	echo " latest $(strip $1): $(strip $3)"
endef

# GET_DEFAULT_VERSION <package> <PACKAGE>
# print default version
define GET_DEFAULT_VERSION
	$(shell \
		sed -n 's,^$(strip $2)_SRC *?= *\([^ ]*\).*,\1,p' \
		$($(strip $2)_DIR)/$(strip $1).mk \
	)
endef

# GET_ARCHIVE_VERSION <package> <head|tail> <url>
# print version of an archive from the web page
define GET_ARCHIVE_VERSION
	$(shell \
		$(call WWW_DUMP, $(strip $3)) | \
		sed -n 's,.*://.*/$(strip $1)-\(.*\)\.$(ARCHIVE_EXT).*,\1,p' | \
		$2 -n1 \
	)
endef
ARCHIVE_EXT := $(shell . $(TOOLS_DIR)/common.sh && env | sed -n 's,^ARCHIVE_EXT=\(.*\),\1,p')
define WWW_DUMP
	$(if $(shell which elinks 2>&-), \
		elinks -dump $1, \
		$(if $(shell which lynx 2>&-), \
			lynx -dump $1, \
			$(error no www-browser able to dump, you should install elinks) \
		) \
	)
endef

# CHECK_LATEST_ARCHIVE_FOR <package> <head|tail> <url>
# print default and latest version from the web page for the package
# filter first or last archive with head or tail
define CHECK_LATEST_ARCHIVE_FOR
	$(call CHECK_LATEST, \
		$1, \
		$(shell echo $1 | tr '[:lower:]' '[:upper:]'), \
		$(call GET_ARCHIVE_VERSION, $1, $2, $3) \
	)
endef

# CHECK_LATEST_ARCHIVE <head|tail> <url>
# print default and latest version from the web page for the implicit package
# filter first or last archive with head or tail
define CHECK_LATEST_ARCHIVE
	$(call CHECK_LATEST_ARCHIVE_FOR, $(@:_check_latest=), $1, $2)
endef
