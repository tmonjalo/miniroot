PKG_MTD-UTILS_BASIC ?= no
PKG_MTD-UTILS_OTP ?= no
PKG_MTD-UTILS_FTL ?= no   # TODO
PKG_MTD-UTILS_NFTL ?= no  # TODO
PKG_MTD-UTILS_RFD ?= no   # TODO
PKG_MTD-UTILS_NAND ?= no  # TODO
PKG_MTD-UTILS_UBI ?= no   # TODO
PKG_MTD-UTILS_JFFS2 ?= no # TODO
MTD-UTILS_SRC ?= 1.2.0
MTD-UTILS_PATCH_DIR ?=
MTD-UTILS_SRC_DIR ?= $(MTD-UTILS_SRC_AUTODIR)
#MTD-UTILS_BUILD_INSIDE = no

MTD-UTILS_DEPS = \
	$(if $(call PKG_IS_SET, $(PKG_MTD-UTILS_JFFS2)), zlib)

MTD-UTILS_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

MTD-UTILS_URL = ftp://ftp.infradead.org/pub/mtd-utils
# if MTD-UTILS_SRC is a version number
ifeq '$(call IS_SRC, $(MTD-UTILS_SRC))' ''
override MTD-UTILS_SRC := $(MTD-UTILS_URL)/mtd-utils-$(strip $(MTD-UTILS_SRC)).tar.bz2
endif

MTD-UTILS_SRC_AUTODIR := $(shell $(TOOLS_DIR)/get_src_dir.sh '$(MTD-UTILS_DIR)' '$(MTD-UTILS_SRC)')
MTD-UTILS_BUILD_DIR := $(if $(MTD-UTILS_BUILD_INSIDE), $(MTD-UTILS_SRC_DIR), $(BUILD_DIR)/$(notdir $(MTD-UTILS_SRC_DIR)))
MTD-UTILS_INSTALL_DIR := $(ROOT_BUILD_DIR)/sbin

MTD-UTILS_BASIC = flashcp flash_erase flash_eraseall flash_lock flash_unlock flash_info
MTD-UTILS_OTP   = flash_otp_write flash_otp_lock flash_otp_info flash_otp_dump

MTD-UTILS_INSTALL_BASIC = $(foreach BIN, $(MTD-UTILS_BASIC), $(MTD-UTILS_INSTALL_DIR)/$(BIN))
MTD-UTILS_INSTALL_OTP   = $(foreach BIN, $(MTD-UTILS_OTP),   $(MTD-UTILS_INSTALL_DIR)/$(BIN))

.PHONY : mtd-utils mtd-utils_init mtd-utils_clean mtd-utils_check_latest
$(eval $(call PKG_INCLUDE_RULE, \
		$(PKG_MTD-UTILS_BASIC) $(PKG_MTD-UTILS_OTP) \
		$(PKG_MTD-UTILS_FTL) $(PKG_MTD-UTILS_NFTL) $(PKG_MTD-UTILS_RFD) $(PKG_MTD-UTILS_NAND) $(PKG_MTD-UTILS_UBI) \
		$(PKG_MTD-UTILS_JFFS2) \
	, mtd-utils))

mtd-utils : $(MTD-UTILS_DEPS) \
	$(if $(call PKG_IS_SET, $(PKG_MTD-UTILS_BASIC)), $(MTD-UTILS_INSTALL_BASIC)) \
	$(if $(call PKG_IS_SET, $(PKG_MTD-UTILS_OTP)),   $(MTD-UTILS_INSTALL_OTP)  ) \
	$(if $(call PKG_IS_SET, $(PKG_MTD-UTILS_FTL)),   $(MTD-UTILS_INSTALL_FTL)  ) \
	$(if $(call PKG_IS_SET, $(PKG_MTD-UTILS_NFTL)),  $(MTD-UTILS_INSTALL_NFTL) ) \
	$(if $(call PKG_IS_SET, $(PKG_MTD-UTILS_RFD)),   $(MTD-UTILS_INSTALL_RFD)  ) \
	$(if $(call PKG_IS_SET, $(PKG_MTD-UTILS_NAND)),  $(MTD-UTILS_INSTALL_NAND) ) \
	$(if $(call PKG_IS_SET, $(PKG_MTD-UTILS_UBI)),   $(MTD-UTILS_INSTALL_UBI)  ) \
	$(if $(call PKG_IS_SET, $(PKG_MTD-UTILS_JFFS2)), $(MTD-UTILS_INSTALL_JFFS2))

mtd-utils_init : $(TOOLCHAIN_DEP)
	@ printf '\n=== MTD-UTILS ===\n'

$(MTD-UTILS_SRC_DIR) :
	@ $(TOOLS_DIR)/init_src.sh '$(MTD-UTILS_DIR)' '$(MTD-UTILS_SRC)' '$@' '$(MTD-UTILS_PATCH_DIR)'

define MTD-UTILS_RULES

$(MTD-UTILS_BUILD_DIR)/$(strip $1) : mtd-utils_init | $(MTD-UTILS_SRC_DIR)
	$(value SET_PATH) $(MAKE) -C $(abspath $(MTD-UTILS_SRC_DIR)) \
		$(SET_CC) $(SET_CFLAGS) $(SET_LDFLAGS) \
		CPPFLAGS='$(TARGET_CPPFLAGS) -I$(abspath $(MTD-UTILS_SRC_DIR)/include)' \
		BUILDDIR=$(abspath $$(@D)) \
		$(abspath $$@)

$(MTD-UTILS_INSTALL_DIR)/$(strip $1) : $(MTD-UTILS_BUILD_DIR)/$(strip $1)
	install -D $$< $$@

endef

$(eval $(foreach BIN, $(MTD-UTILS_BASIC), $(call MTD-UTILS_RULES, $(BIN))))
$(eval $(foreach BIN, $(MTD-UTILS_OTP),   $(call MTD-UTILS_RULES, $(BIN))))

mtd-utils_clean :
	- $(MAKE) -C $(MTD-UTILS_SRC_DIR) clean \
		$(if $(MTD-UTILS_BUILD_INSIDE), , BUILDDIR='$(abspath $(MTD-UTILS_BUILD_DIR))') \

mtd-utils_check_latest :
	@ $(call CHECK_LATEST_ARCHIVE, tail, $(MTD-UTILS_URL))
