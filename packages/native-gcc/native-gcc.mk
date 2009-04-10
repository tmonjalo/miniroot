##
## config.mk available options ##
##
# A target prefix for the target rootfs.
# Could be, f.e., /usr/local, or /opt/, or whatever..
NATIVEGCC_TARGET_PREFIX	?= 
# A prefix where we would find the native gcc binaries, libs and includes
NATIVEGCC_PREFIX		?= $(CROSS_PATH)/$(CROSS_PREFIX:-=)
# The binaries, lib and includes folders to copy to rootfs
NATIVEGCC_DIRECTORIES	?= bin lib sys-include
# Verbosity of native-gcc installation
SET_NATIVEGCC_VERBOSE	= $(if $(VERBOSE),NATIVEGCC_VERBOSE="yes")
##
## end of config.mk tunable variables ##
##

NATIVEGCC_INSTALLDIR = $(ROOT_BUILD_DIR)/$(NATIVEGCC_TARGET_PREFIX)

.PHONY: native-gcc native-gcc_install
$(eval $(call PKG_INCLUDE_RULE, $(PKG_NATIVEGCC), native-gcc))

# An empty rule to make it more readable from packages.mk
native-gcc: native-gcc_install

# The real stuff
native-gcc_install: 
	@echo "== NATIVE GCC =="
	@$(foreach DIR,$(NATIVEGCC_DIRECTORIES),\
		$(if $(NATIVEGCC_VERBOSE),echo,:) "Installing $(DIR)..." ; \
		mkdir -p $(NATIVEGCC_INSTALLDIR)/$(DIR) ;\
		tar -cC $(NATIVEGCC_PREFIX)/$(DIR) . | tar -xC $(NATIVEGCC_INSTALLDIR)/$(DIR) ;\
	)

