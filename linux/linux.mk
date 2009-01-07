.PHONY: linux linux_init
all: linux

LINUX_VERBOSE = 0

ifeq ($(strip $(LINUX_SRC)),)
LINUX_SRC = linux-$(strip $(LINUX_VERSION)).tar.bz2
LINUX_URL = http://www.kernel.org/pub/linux/kernel/v2.6/$(LINUX_SRC)
LINUX_TARBALL = $(LINUX_DIR)/$(LINUX_SRC)
endif

LINUX_SRC_DIR = $(LINUX_DIR)/$(shell \
	if [ -d $(LINUX_DIR)/$(LINUX_SRC) ] ; then \
		echo $(LINUX_SRC) ; \
	else \
		tar tf $(LINUX_DIR)/$(LINUX_SRC) | head -n1 | sed 's:/*$$::' ; \
	fi \
)
LINUX_BUILD_DIR = $(BUILD_DIR)/$(LINUX_DIR)

LINUX_MAKE = PATH="$(CROSS_PATH)/bin:$$PATH" make -C $(LINUX_SRC_DIR) \
	ARCH=$(CROSS_ARCH) CROSS_COMPILE=$(CROSS_PREFIX) CC=$(CROSS_CC) \
	V=$(LINUX_VERBOSE) O=$(abspath $(BUILD_DIR)/$(LINUX_DIR))

linux_%: linux_init
	$(LINUX_MAKE) $*

linux: linux_init
	$(LINUX_MAKE)

linux_init: $(LINUX_TARBALL)
	[ -d "$(LINUX_SRC_DIR)" ] || \
		tar x -C $(LINUX_DIR) -f $(LINUX_DIR)/$(LINUX_TARBALL)
	mkdir -p $(LINUX_BUILD_DIR)
	[ -f $(LINUX_BUILD_DIR)/.config ] || \
		if [ -f $(LINUX_DIR)/$(LINUX_CONFIG) ] ; then \
			cp $(LINUX_DIR)/$(LINUX_CONFIG) $(LINUX_BUILD_DIR)/.config ; \
		else \
			cp $(LINUX_SRC_DIR)/arch/$(CROSS_ARCH)/configs/$(LINUX_CONFIG) $(LINUX_BUILD_DIR)/.config ; \
		fi

$(LINUX_TARBALL):
	wget -P $(LINUX_DIR) $(LINUX_URL)
