# options can be set in config.mk
PKG_MDADM ?= no
MDADM_SRC ?= 2.6.9
MDADM_PATCH_DIR ?= # [directory]
#MDADM_BUILD_INSIDE = no

MDADM_DEPS =

# if MDADM_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(MDADM_SRC)')),false)
override MDADM_SRC := $(MDADM_DIR)/mdadm-$(strip $(MDADM_SRC)).tar.bz2
MDADM_URL = http://www.kernel.org/pub/linux/utils/raid/mdadm/$(notdir $(MDADM_SRC))
endif

MDADM_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(MDADM_DIR)' '$(MDADM_SRC)')
MDADM_BUILD_DIR = $(if $(MDADM_BUILD_INSIDE), $(MDADM_SRC_DIR), $(BUILD_DIR)/$(notdir $(MDADM_SRC_DIR)))
MDADM_BUILD_BIN = $(MDADM_BUILD_DIR)/mdadm
MDADM_INSTALL_BIN = $(ROOT_BUILD_DIR)/sbin/$(notdir $(MDADM_BUILD_BIN))

.PHONY: mdadm_mkfs mdadm_init mdadm_libs mdadm_clean
$(eval $(call PKG_INCLUDE_RULE, $(PKG_MDADM), mdadm))

mdadm: $(MDADM_DEPS) $(MDADM_INSTALL_BIN)

mdadm_init:
	@ echo '=== MDADM ==='
	@ $(TOOLS_DIR)/init_src.sh '$(MDADM_DIR)' '$(MDADM_SRC)' '$(MDADM_URL)' '$(MDADM_PATCH_DIR)'

$(MDADM_BUILD_DIR)/Makefile:
	mkdir -p $(MDADM_BUILD_DIR)
	( cd $(MDADM_BUILD_DIR) && \
		$(SET_CROSS_PATH) $(SET_CROSS_CC) $(SET_CFLAGS) $(SET_LDFLAGS) \
		$(abspath $(MDADM_SRC_DIR))/configure \
		$(CONFIGURE_CROSS_HOST) \
			--srcdir='$(abspath $(MDADM_SRC_DIR))'
	)

$(MDADM_BUILD_BIN): mdadm_init $(MDADM_BUILD_DIR)/Makefile
	$(SET_CROSS_PATH) $(MAKE) -C $(MDADM_BUILD_DIR) $(notdir $(MDADM_BUILD_BIN))

$(MDADM_INSTALL_BIN): $(MDADM_BUILD_BIN)
	install -D $(MDADM_BUILD_BIN) $(MDADM_INSTALL_BIN)

mdadm_clean:
	- $(MAKE) -C $(MDADM_BUILD_DIR) clean
