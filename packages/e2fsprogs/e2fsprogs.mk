# options can be set in config.mk
PKG_E2FSPROGS_MKFS ?= no
E2FSPROGS_SRC ?= 1.41.4
E2FSPROGS_PATCH_DIR ?= # [directory]
#E2FSPROGS_BUILD_INSIDE = no

E2FSPROGS_DEPS =

# if E2FSPROGS_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(E2FSPROGS_SRC)')),false)
override E2FSPROGS_SRC := $(E2FSPROGS_DIR)/e2fsprogs-$(strip $(E2FSPROGS_SRC)).tar.gz
E2FSPROGS_URL = http://downloads.sourceforge.net/e2fsprogs/$(notdir $(E2FSPROGS_SRC))
endif

E2FSPROGS_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(E2FSPROGS_DIR)' '$(E2FSPROGS_SRC)')
E2FSPROGS_BUILD_DIR = $(if $(E2FSPROGS_BUILD_INSIDE), $(E2FSPROGS_SRC_DIR), $(BUILD_DIR)/$(notdir $(E2FSPROGS_SRC_DIR)))
E2FSPROGS_BUILD_MKFS = $(E2FSPROGS_BUILD_DIR)/misc/mke2fs
E2FSPROGS_INSTALL_MKFS = $(ROOT_BUILD_DIR)/sbin/$(notdir $(E2FSPROGS_BUILD_MKFS))

.PHONY: e2fsprogs_mkfs e2fsprogs_init e2fsprogs_libs e2fsprogs_clean
$(eval $(call PKG_INCLUDE_RULE, $(PKG_E2FSPROGS_MKFS), e2fsprogs))

e2fsprogs: $(E2FSPROGS_DEPS) \
	$(if $(call PKG_IS_SET, $(PKG_E2FSPROGS_MKFS)), $(E2FSPROGS_INSTALL_MKFS))

e2fsprogs_init:
	@ echo '=== E2FSPROGS ==='
	@ $(TOOLS_DIR)/init_src.sh '$(E2FSPROGS_DIR)' '$(E2FSPROGS_SRC)' '$(E2FSPROGS_URL)' '$(E2FSPROGS_PATCH_DIR)'

$(E2FSPROGS_BUILD_DIR)/Makefile:
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

e2fsprogs_libs: e2fsprogs_init $(E2FSPROGS_BUILD_DIR)/Makefile
	$(SET_CROSS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/et
	$(SET_CROSS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/ext2fs
	$(SET_CROSS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/e2p
	$(SET_CROSS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/blkid
	$(SET_CROSS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/uuid

$(E2FSPROGS_BUILD_MKFS): e2fsprogs_libs
	$(SET_CROSS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/misc $(notdir $(E2FSPROGS_BUILD_MKFS))

$(E2FSPROGS_INSTALL_MKFS): $(E2FSPROGS_BUILD_MKFS)
	install -D $< $(E2FSPROGS_INSTALL_MKFS)

e2fsprogs_clean:
	$(MAKE) -C $(E2FSPROGS_BUILD_DIR) clean
