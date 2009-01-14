# options can be enabled in config.mk
#LINUX_BUILD_INSIDE = y
#LINUX_VERBOSE = y

# if LINUX_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(LINUX_DIR)' '$(LINUX_SRC)')),false)
override LINUX_SRC := linux-$(strip $(LINUX_SRC)).tar.bz2
LINUX_URL = http://www.kernel.org/pub/linux/kernel/v2.6/$(LINUX_SRC)
endif

LINUX_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(LINUX_DIR)' '$(LINUX_SRC)')
LINUX_BUILD_DIR = $(if $(LINUX_BUILD_INSIDE), $(LINUX_SRC_DIR), $(BUILD_DIR)/$(notdir $(LINUX_SRC_DIR)))
LINUX_BUILD_CONFIG = $(LINUX_BUILD_DIR)/.config

LINUX_MAKE = $(SET_CROSS_PATH) $(MAKE) -C $(LINUX_SRC_DIR) \
	$(SET_CROSS_ARCH) $(SET_CROSS_COMPILE) $(SET_CROSS_CC) \
	$(if $(LINUX_BUILD_INSIDE), , O='$(abspath $(LINUX_BUILD_DIR))') \
	$(if $(LINUX_VERBOSE), V=1)

.PHONY: linux linux_init linux_build
clean: linux_clean

linux: linux_init $(LINUX_BUILD_CONFIG) linux_build

linux_%: linux_init $(LINUX_BUILD_CONFIG)
	$(LINUX_MAKE) $*

linux_build:
	$(LINUX_MAKE)

linux_init:
	@ echo '=== LINUX ==='
	@ $(TOOLS_DIR)/init_src.sh '$(LINUX_DIR)' '$(LINUX_SRC)' '$(LINUX_URL)' '$(LINUX_PATCH_DIR)'

$(LINUX_BUILD_CONFIG):
	mkdir -p $(LINUX_BUILD_DIR)
	@ echo copy config to $(LINUX_BUILD_CONFIG)
	@ if [ -f '$(LINUX_DIR)/$(LINUX_CONFIG)' ] ; then \
		cp $(LINUX_DIR)/$(LINUX_CONFIG) $(LINUX_BUILD_CONFIG) ; \
	else \
		cp $(LINUX_SRC_DIR)/arch/$(CROSS_ARCH)/configs/$(LINUX_CONFIG) $(LINUX_BUILD_CONFIG) ; \
	fi
	yes '' | $(LINUX_MAKE) oldconfig
