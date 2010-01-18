PKG_E2FSPROGS_MKFS ?= no
E2FSPROGS_SRC ?= 1.41.8
E2FSPROGS_PATCH_DIR ?=
E2FSPROGS_SRC_DIR ?= $(E2FSPROGS_SRC_AUTODIR)
#E2FSPROGS_BUILD_INSIDE = no

E2FSPROGS_DEPS =

E2FSPROGS_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

E2FSPROGS_URL = http://downloads.sourceforge.net/e2fsprogs
# if E2FSPROGS_SRC is a version number
ifeq '$(call IS_SRC, $(E2FSPROGS_SRC))' ''
override E2FSPROGS_SRC := $(E2FSPROGS_URL)/e2fsprogs-$(strip $(E2FSPROGS_SRC)).tar.gz
endif

E2FSPROGS_SRC_AUTODIR := $(shell $(TOOLS_DIR)/get_src_dir.sh '$(E2FSPROGS_DIR)' '$(E2FSPROGS_SRC)')
E2FSPROGS_BUILD_DIR := $(if $(E2FSPROGS_BUILD_INSIDE), $(E2FSPROGS_SRC_DIR), $(BUILD_DIR)/$(notdir $(E2FSPROGS_SRC_DIR)))
E2FSPROGS_BUILD_MAKEFILE := $(E2FSPROGS_BUILD_DIR)/Makefile
E2FSPROGS_BUILD_MKFS := $(E2FSPROGS_BUILD_DIR)/misc/mke2fs
E2FSPROGS_INSTALL_MKFS := $(ROOT_BUILD_DIR)/sbin/$(notdir $(E2FSPROGS_BUILD_MKFS))

.PHONY : e2fsprogs_mkfs e2fsprogs_init e2fsprogs_libs e2fsprogs_clean e2fsprogs_check_latest
$(eval $(call PKG_INCLUDE_RULE, $(PKG_E2FSPROGS_MKFS), e2fsprogs))

e2fsprogs : $(E2FSPROGS_DEPS) \
	$(if $(call PKG_IS_SET, $(PKG_E2FSPROGS_MKFS)), $(E2FSPROGS_INSTALL_MKFS))

e2fsprogs_init : $(TOOLCHAIN_DEP)
	@ printf '\n=== E2FSPROGS ===\n'

$(E2FSPROGS_SRC_DIR) :
	@ $(TOOLS_DIR)/init_src.sh '$(E2FSPROGS_DIR)' '$(E2FSPROGS_SRC)' '$@' '$(E2FSPROGS_PATCH_DIR)'

$(E2FSPROGS_BUILD_MAKEFILE) : | $(E2FSPROGS_SRC_DIR)
	mkdir -p $(@D)
	cd $(@D) && \
		$(SET_PATH) $(SET_CC) $(SET_CFLAGS) $(SET_LDFLAGS) \
		$(abspath $(E2FSPROGS_SRC_DIR))/configure \
		$(CONFIGURE_HOST) \
			--srcdir='$(abspath $(E2FSPROGS_SRC_DIR))' \
			--disable-testio-debug \
			--disable-debugfs \
			--disable-imager \
			--disable-resizer \
			--disable-fsck \
			--disable-e2initrd-helper \
			--disable-tls \
			--disable-uuidd \
			--disable-nls

e2fsprogs_libs : e2fsprogs_init $(E2FSPROGS_BUILD_MAKEFILE)
	$(SET_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/et
	$(SET_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/ext2fs
	$(SET_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/e2p
	$(SET_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/blkid
	$(SET_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/uuid

$(E2FSPROGS_BUILD_MKFS) : e2fsprogs_libs
	$(SET_PATH) $(MAKE) -C $(@D) $(@F)

$(E2FSPROGS_INSTALL_MKFS) : $(E2FSPROGS_BUILD_MKFS)
	install -D $< $@

e2fsprogs_clean :
	- $(MAKE) -C $(E2FSPROGS_BUILD_DIR) clean

e2fsprogs_check_latest :
	@ $(call CHECK_LATEST_ARCHIVE, head, http://e2fsprogs.sourceforge.net)
