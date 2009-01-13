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
BUSYBOX_INSTALL_DIR = $(BUILD_DIR)/$(ROOT_DIR)

BUSYBOX_MAKE = $(SET_CROSS_PATH) $(MAKE) -C $(BUSYBOX_SRC_DIR) \
	$(SET_CROSS_COMPILE) $(SET_CROSS_CC) \
	$(if $(BUSYBOX_BUILD_INSIDE), , O='$(abspath $(BUSYBOX_BUILD_DIR))') \
	CONFIG_PREFIX='$(abspath $(BUSYBOX_INSTALL_DIR))' \
	$(if $(BUSYBOX_VERBOSE), V=1)

.PHONY: busybox busybox_init
clean: busybox_clean

busybox_%: busybox_init
	$(BUSYBOX_MAKE) $*

busybox: busybox_init
	@ echo '=== BUSYBOX ==='
	$(BUSYBOX_MAKE) install
	$(call STRIP, $(BUSYBOX_INSTALL_DIR)/bin/busybox)

busybox_clean:
	$(BUSYBOX_MAKE) clean uninstall

busybox_init:
	@ $(TOOLS_DIR)/init_src.sh '$(BUSYBOX_DIR)' '$(BUSYBOX_SRC)' '$(BUSYBOX_URL)' '$(BUSYBOX_PATCH_DIR)'
	@ mkdir -p $(BUSYBOX_BUILD_DIR)
	@ if [ ! -f $(BUSYBOX_BUILD_DIR)/.config ] ; then \
		echo copy config to $(BUSYBOX_BUILD_DIR)/.config ; \
		if [ -f '$(BUSYBOX_DIR)/$(BUSYBOX_CONFIG)' ] ; then \
			cp $(BUSYBOX_DIR)/$(BUSYBOX_CONFIG) $(BUSYBOX_BUILD_DIR)/.config ; \
			yes '' | $(BUSYBOX_MAKE) oldconfig ; \
		else \
			$(BUSYBOX_MAKE) defconfig ; \
		fi ; \
	fi
