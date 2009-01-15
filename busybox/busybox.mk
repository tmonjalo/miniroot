# options can be enabled in config.mk
#BUSYBOX_BUILD_INSIDE = y
#BUSYBOX_VERBOSE = y

# if BUSYBOX_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(BUSYBOX_DIR)' '$(BUSYBOX_SRC)')),false)
override BUSYBOX_SRC := busybox-$(strip $(BUSYBOX_SRC)).tar.bz2
BUSYBOX_URL = http://busybox.net/downloads/$(BUSYBOX_SRC)
endif

BUSYBOX_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(BUSYBOX_DIR)' '$(BUSYBOX_SRC)')
BUSYBOX_BUILD_DIR = $(if $(BUSYBOX_BUILD_INSIDE), $(BUSYBOX_SRC_DIR), $(BUILD_DIR)/$(notdir $(BUSYBOX_SRC_DIR)))
BUSYBOX_BUILD_CONFIG = $(BUSYBOX_BUILD_DIR)/.config
BUSYBOX_BUILD_BIN = $(BUSYBOX_BUILD_DIR)/busybox
BUSYBOX_INSTALL_DIR = $(BUILD_DIR)/$(ROOT_DIR)
BUSYBOX_INSTALL_BIN = $(BUSYBOX_INSTALL_DIR)/bin/busybox

BUSYBOX_MAKE = $(SET_CROSS_PATH) $(MAKE) -C $(BUSYBOX_SRC_DIR) \
	$(SET_CROSS_COMPILE) $(SET_CROSS_CC) \
	$(if $(BUSYBOX_BUILD_INSIDE), , O='$(abspath $(BUSYBOX_BUILD_DIR))') \
	CONFIG_PREFIX='$(abspath $(BUSYBOX_INSTALL_DIR))' \
	$(if $(BUSYBOX_VERBOSE), V=1)

.PHONY: busybox busybox_init busybox_build
clean: busybox_clean

# wildcard rule
busybox_%: busybox_init $(BUSYBOX_BUILD_CONFIG)
	$(BUSYBOX_MAKE) $*

# scheduling rule
busybox: busybox_init $(BUSYBOX_BUILD_CONFIG) busybox_build $(BUSYBOX_INSTALL_BIN)

busybox_init:
	@ echo '=== BUSYBOX ==='
	@ $(TOOLS_DIR)/init_src.sh '$(BUSYBOX_DIR)' '$(BUSYBOX_SRC)' '$(BUSYBOX_URL)' '$(BUSYBOX_PATCH_DIR)'

$(BUSYBOX_BUILD_DIR):
	mkdir -p $(BUSYBOX_BUILD_DIR)

$(BUSYBOX_BUILD_CONFIG): $(BUSYBOX_BUILD_DIR)
	@ echo copy config to $(BUSYBOX_BUILD_CONFIG)
	@ if [ -f '$(BUSYBOX_DIR)/$(BUSYBOX_CONFIG)' ] ; then \
		cp $(BUSYBOX_DIR)/$(BUSYBOX_CONFIG) $(BUSYBOX_BUILD_CONFIG) ; \
		yes '' | $(BUSYBOX_MAKE) oldconfig ; \
	else \
		$(BUSYBOX_MAKE) defconfig ; \
	fi

$(BUSYBOX_BUILD_BIN): busybox_build

busybox_build: busybox_busybox

$(BUSYBOX_INSTALL_BIN): $(BUSYBOX_BUILD_BIN)
	$(BUSYBOX_MAKE) install
	$(CROSS_STRIP) $(BUSYBOX_INSTALL_BIN)

busybox_clean:
	$(BUSYBOX_MAKE) clean uninstall
