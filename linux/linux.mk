.PHONY: linux linux_init
all: linux
clean: linux_clean

LINUX_BUILD_OUT = O=$(abspath $(LINUX_BUILD_DIR))
LINUX_VERBOSE = V=0

# if LINUX_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(LINUX_SRC)')),false)
override LINUX_SRC := linux-$(strip $(LINUX_SRC)).tar.bz2
LINUX_URL = http://www.kernel.org/pub/linux/kernel/v2.6/$(LINUX_SRC)
endif

LINUX_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(LINUX_DIR)' '$(LINUX_SRC)')
LINUX_BUILD_DIR = $(BUILD_DIR)/$(LINUX_DIR)

LINUX_MAKE = PATH="$(CROSS_PATH)/bin:$$PATH" make -C $(LINUX_SRC_DIR) \
	ARCH=$(CROSS_ARCH) CROSS_COMPILE=$(CROSS_PREFIX) CC=$(CROSS_CC) \
	$(LINUX_BUILD_OUT) $(LINUX_VERBOSE)

linux_%: linux_init
	$(LINUX_MAKE) $*

linux: linux_init
	$(LINUX_MAKE)

linux_init:
	@ $(TOOLS_DIR)/init_src.sh '$(LINUX_DIR)' '$(LINUX_SRC)' '$(LINUX_URL)' '$(LINUX_PATCH_DIR)'
	@ mkdir -p $(LINUX_BUILD_DIR)
	@ if [ ! -f $(LINUX_BUILD_DIR)/.config ] ; then \
		echo copy config to $(LINUX_BUILD_DIR)/.config ; \
		if [ -f '$(LINUX_DIR)/$(LINUX_CONFIG)' ] ; then \
			cp $(LINUX_DIR)/$(LINUX_CONFIG) $(LINUX_BUILD_DIR)/.config ; \
		else \
			cp $(LINUX_SRC_DIR)/arch/$(CROSS_ARCH)/configs/$(LINUX_CONFIG) $(LINUX_BUILD_DIR)/.config ; \
		fi ; \
	fi
