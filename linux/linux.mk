.PHONY: linux linux_config linux_subdir
all: linux

ifeq ($(strip $(LINUX_SRC)),)
LINUX_SRC = linux-$(strip $(LINUX_VERSION)).tar.bz2
LINUX_URL = http://www.kernel.org/pub/linux/kernel/v2.6/$(LINUX_SRC)
LINUX_TARBALL = $(LINUX_DIR)/$(LINUX_SRC)
endif

LINUX_SUBDIR = $(LINUX_DIR)/$(shell \
	if [ -d $(LINUX_DIR)/$(LINUX_SRC) ] ; then \
		echo $(LINUX_SRC) ; \
	else \
		tar tf $(LINUX_DIR)/$(LINUX_SRC) | head -n1 | sed 's:/*$$::' ; \
	fi \
)

LINUX_MAKE = PATH="$(CROSS_PATH):$$PATH" make -C $(LINUX_SUBDIR) \
	ARCH=$(CROSS_ARCH) CROSS_COMPILE=$(CROSS_PREFIX) CC=$(CROSS_CC) CFLAGS=$(CROSS_CFLAGS)

linux_config: linux_subdir
	$(LINUX_MAKE) menuconfig

linux: linux_subdir
	$(LINUX_MAKE) oldconfig
	$(LINUX_MAKE)

linux_subdir: $(LINUX_TARBALL)
	[ -d "$(LINUX_SUBDIR)" ] || \
		tar x -C $(LINUX_DIR) -f $(LINUX_DIR)/$(LINUX_TARBALL)
	[ -f $(LINUX_SUBDIR)/.config ] || \
		if [ -f $(LINUX_DIR)/$(LINUX_CONFIG) ] ; then \
			cp $(LINUX_DIR)/$(LINUX_CONFIG) $(LINUX_SUBDIR)/.config ; \
		else \
			cp $(LINUX_SUBDIR)/arch/$(CROSS_ARCH)/configs/$(LINUX_CONFIG) $(LINUX_SUBDIR)/.config ; \
		fi

$(LINUX_TARBALL):
	wget -P $(LINUX_DIR) $(LINUX_URL)
