
# A target prefix for the target rootfs.
# Could be, f.e., /usr/local, or /opt/, or whatever..
TARGET_PREFIX ?= 

NATIVEGCC_PREFIX		= $(if $(CROSS_PATH),$(CROSS_PATH)/)$(patsubst %-,%,$(CROSS_PREFIX))
# The folders where we could find anything needed to compile on target.
NATIVEGCC_DIRECTORIES	?= bin lib sys-include
NATIVEGCC_INSTALLDIR	= $(ROOT_BUILD_DIR)/$(TARGET_PREFIX)

.PHONY: native-gcc native-gcc_install
$(eval $(call PKG_INCLUDE_RULE, $(PKG_NATIVEGCC), native-gcc))

native-gcc: native-gcc_install
native-gcc_install: 
	@echo "== NATIVE GCC INSTALL =="
	$(foreach DIR,$(NATIVEGCC_DIRECTORIES),\
		echo "$(DIR)..." ; \
		mkdir -p $(NATIVEGCC_INSTALLDIR)/$(DIR) ;\
		tar -cC $(NATIVEGCC_PREFIX)/$(DIR) . | tar -xC $(NATIVEGCC_INSTALLDIR)/$(DIR) ;\
	)
