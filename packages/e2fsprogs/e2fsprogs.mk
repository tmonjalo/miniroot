# options can be set in config.mk
E2FSPROGS_SRC ?= 1.41.4
#E2FSPROGS_PATCH_DIR = [directory]
#E2FSPROGS_BUILD_INSIDE = yes

E2FSPROGS_DEPS =

# if E2FSPROGS_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(E2FSPROGS_SRC)')),false)
override E2FSPROGS_SRC := $(E2FSPROGS_DIR)/e2fsprogs-$(strip $(E2FSPROGS_SRC)).tar.gz
E2FSPROGS_URL = http://downloads.sourceforge.net/e2fsprogs/$(notdir $(E2FSPROGS_SRC))
endif

E2FSPROGS_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(E2FSPROGS_DIR)' '$(E2FSPROGS_SRC)')
E2FSPROGS_BUILD_DIR = $(if $(E2FSPROGS_BUILD_INSIDE), $(E2FSPROGS_SRC_DIR), $(BUILD_DIR)/$(notdir $(E2FSPROGS_SRC_DIR)))
E2FSPROGS_BUILD_MKFS_BIN = $(E2FSPROGS_BUILD_DIR)/misc/mke2fs
E2FSPROGS_INSTALL_MKFS_BIN = $(ROOT_BUILD_DIR)/sbin/$(notdir $(E2FSPROGS_BUILD_MKFS_BIN))

.PHONY: e2fsprogs_mkfs e2fsprogs_init ee2fsprogs_configure 2fsprogs_clean 
$(eval $(call PKG_INCLUDE_RULE, $(PKG_E2FSPROGS_MKFS), e2fsprogs_mkfs))

e2fsprogs_mkfs: $(E2FSPROGS_DEPS) $(E2FSPROGS_INSTALL_MKFS_BIN)

e2fsprogs_init:
	@ echo '=== E2FSPROGS ==='
	@ $(TOOLS_DIR)/init_src.sh '$(E2FSPROGS_DIR)' '$(E2FSPROGS_SRC)' '$(E2FSPROGS_URL)' '$(E2FSPROGS_PATCH_DIR)'

e2fsprogs_configure:
	mkdir -p $(E2FSPROGS_BUILD_DIR)
	( cd $(E2FSPROGS_BUILD_DIR) && \
		$(SET_CROSS_PATH) $(SET_CROSS_CC) $(SET_CFLAGS) $(SET_LDFLAGS) \
		$(abspath $(E2FSPROGS_SRC_DIR))/configure \
		$(CONFIGURE_CROSS_HOST) \
			--srcdir='$(abspath $(E2FSPROGS_SRC_DIR))' \
			--disable-testio-debug \
			--disable-debugfs \
			--disable-imager \
			--disable-resizer \
			--disable-fsck \
			--disable-e2initrd-helper \
			--disable-tls \
			--disable-uuidd \
			--disable-nls \
	)

$(E2FSPROGS_BUILD_MKFS_BIN): e2fsprogs_init e2fsprogs_configure
	$(SET_CROSS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR) misc/$(notdir $(E2FSPROGS_BUILD_MKFS_BIN))

$(E2FSPROGS_INSTALL_MKFS_BIN): $(E2FSPROGS_BUILD_MKFS_BIN)
	install -D $< $@

e2fsprogs_clean:
	$(MAKE) -C $(E2FSPROGS_BUILD_DIR) clean
