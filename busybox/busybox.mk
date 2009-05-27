# options can be set in config.mk
BUSYBOX_SRC ?= 1.13.4 # <version | directory | tarball | VCS URL>
BUSYBOX_PATCH_DIR ?= # [directory]
BUSYBOX_CONFIG ?= # [file]
#BUSYBOX_BUILD_INSIDE = no
#BUSYBOX_VERBOSE = no

# if BUSYBOX_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(BUSYBOX_SRC)')),false)
override BUSYBOX_SRC := $(BUSYBOX_DIR)/busybox-$(strip $(BUSYBOX_SRC)).tar.bz2
BUSYBOX_URL = http://busybox.net/downloads/$(notdir $(BUSYBOX_SRC))
endif

BUSYBOX_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(BUSYBOX_DIR)' '$(BUSYBOX_SRC)')
BUSYBOX_BUILD_DIR = $(if $(BUSYBOX_BUILD_INSIDE), $(BUSYBOX_SRC_DIR), $(BUILD_DIR)/$(notdir $(BUSYBOX_SRC_DIR)))
BUSYBOX_BUILD_CONFIG = $(BUSYBOX_BUILD_DIR)/.config
BUSYBOX_BUILD_BIN = $(BUSYBOX_BUILD_DIR)/busybox
BUSYBOX_INSTALL_BIN = $(ROOT_BUILD_DIR)/bin/busybox

BUSYBOX_MAKE = $(SET_PATH) $(MAKE) -C $(BUSYBOX_SRC_DIR) \
	$(if $(BUSYBOX_BUILD_INSIDE), , O='$(abspath $(BUSYBOX_BUILD_DIR))') \
	$(if $(BUSYBOX_VERBOSE), V=1) \
	$(SET_CROSS_COMPILE) $(SET_CC) $(SET_CFLAGS) $(SET_LDFLAGS) \
	CONFIG_PREFIX='$(abspath $(ROOT_BUILD_DIR))'

.PHONY: busybox busybox_init busybox_clean
clean: busybox_clean

busybox: $(BUSYBOX_INSTALL_BIN)

busybox_init:
	@ echo '=== BUSYBOX ==='
	@ $(TOOLS_DIR)/init_src.sh '$(BUSYBOX_DIR)' '$(BUSYBOX_SRC)' '$(BUSYBOX_URL)' '$(BUSYBOX_PATCH_DIR)'

$(BUSYBOX_BUILD_CONFIG):
	mkdir -p $(BUSYBOX_BUILD_DIR)
	@ echo 'copy config to $(BUSYBOX_BUILD_CONFIG)'
	@ if [ -f '$(strip $(BUSYBOX_CONFIG))' ] ; then \
		echo $(BUSYBOX_BUILD_CONFIG) ; \
		cp $(BUSYBOX_CONFIG) $(BUSYBOX_BUILD_CONFIG) && \
		yes '' | $(BUSYBOX_MAKE) oldconfig ; \
	else \
		$(BUSYBOX_MAKE) defconfig ; \
	fi

# wildcard rule
busybox_%: busybox_init $(BUSYBOX_BUILD_CONFIG)
	$(BUSYBOX_MAKE) $*

$(BUSYBOX_BUILD_BIN): busybox_busybox
	@ : # nop rule to make install working

$(BUSYBOX_INSTALL_BIN): $(BUSYBOX_BUILD_BIN)
	$(BUSYBOX_MAKE) install
	chmod 4755 $(BUSYBOX_INSTALL_BIN)

busybox_clean:
	- $(BUSYBOX_MAKE) clean uninstall
