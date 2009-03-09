# options can be set in config.mk
E2FSPROGS_SRC ?= 1.41.4
#E2FSPROGS_PATCH_DIR = [directory]
#E2FSPROGS_BUILD_INSIDE = no

E2FSPROGS_DEPS =

# if E2FSPROGS_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(E2FSPROGS_SRC)')),false)
override E2FSPROGS_SRC := $(E2FSPROGS_DIR)/e2fsprogs-$(strip $(E2FSPROGS_SRC)).tar.gz
E2FSPROGS_URL = http://downloads.sourceforge.net/e2fsprogs/$(notdir $(E2FSPROGS_SRC))
endif

E2FSPROGS_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(E2FSPROGS_DIR)' '$(E2FSPROGS_SRC)')
E2FSPROGS_BUILD_DIR = $(if $(E2FSPROGS_BUILD_INSIDE), $(E2FSPROGS_SRC_DIR), $(BUILD_DIR)/$(notdir $(E2FSPROGS_DIR)))
E2FSPROGS_BUILD_BIN = $(E2FSPROGS_BUILD_DIR)/mke2fs
E2FSPROGS_INSTALL_BIN = $(ROOT_BUILD_DIR)/sbin/$(notdir $(E2FSPROGS_BUILD_BIN))

.PHONY: e2fsprogs e2fsprogs_init e2fsprogs_clean
$(eval $(call PKG_INCLUDE_RULE, $(PKG_E2FSPROGS_MKFS), e2fsprogs))

e2fsprogs: $(E2FSPROGS_DEPS) $(E2FSPROGS_INSTALL_BIN)

e2fsprogs_init:
	@ echo '=== E2FSPROGS ==='
	@ $(TOOLS_DIR)/init_src.sh '$(E2FSPROGS_DIR)' '$(E2FSPROGS_SRC)' '$(E2FSPROGS_URL)' '$(E2FSPROGS_PATCH_DIR)'

$(E2FSPROGS_BUILD_BIN): e2fsprogs_init
	false
	$(SET_CROSS_PATH) $(MAKE) -C $(E2FSPROGS_SRC_DIR) $(abspath $@) \
		$(if $(E2FSPROGS_BUILD_INSIDE), , O='$(abspath $(E2FSPROGS_BUILD_DIR))') \
		$(SET_CROSS_CC) $(SET_CPPFLAGS) $(SET_CFLAGS) $(SET_LDFLAGS)

$(E2FSPROGS_INSTALL_BIN): $(E2FSPROGS_BUILD_BIN)
	install -D $< $@

e2fsprogs_clean:
	$(MAKE) -C $(E2FSPROGS_SRC_DIR) clean \
		$(if $(E2FSPROGS_BUILD_INSIDE), , O='$(abspath $(E2FSPROGS_BUILD_DIR))')
