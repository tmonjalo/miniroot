# options can be set in config.mk
LINUX_SRC ?= 2.6.30.5 # <version | directory | tarball | VCS URL>
LINUX_PATCH_DIR ?= # [directory]
LINUX_CONFIG ?= # <file>
LINUX_SRC_DIR ?= $(shell $(TOOLS_DIR)/get_src_dir.sh '$(LINUX_DIR)' '$(LINUX_SRC)')
#LINUX_BUILD_INSIDE = no
#LINUX_VERBOSE = no
LINUX_TOOLCHAIN_PATH ?= $(TOOLCHAIN_PATH)
LINUX_TOOLCHAIN_PREFIX ?= $(TOOLCHAIN_PREFIX)
LINUX_TARGET_CC ?= $(TARGET_CC)

LINUX_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

LINUX_URL = http://kernel.org/pub/linux/kernel/v2.6
# if LINUX_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(LINUX_SRC)')),false)
override LINUX_SRC := $(LINUX_URL)/linux-$(strip $(LINUX_SRC)).tar.bz2
endif

LINUX_BUILD_DIR = $(if $(LINUX_BUILD_INSIDE), $(LINUX_SRC_DIR), $(BUILD_DIR)/$(notdir $(LINUX_SRC_DIR)))
LINUX_BUILD_CONFIG = $(LINUX_BUILD_DIR)/.config
LINUX_DEFAULT_CONFIG = $(LINUX_SRC_DIR)/arch/$(TARGET_ARCH)/configs/$(LINUX_CONFIG)

LINUX_MAKE = $(SET_LINUX_PATH) $(MAKE) -C $(LINUX_SRC_DIR) \
	$(SET_ARCH) $(SET_LINUX_CROSS_COMPILE) $(SET_LINUX_CC) \
	$(if $(LINUX_BUILD_INSIDE), , O='$(abspath $(LINUX_BUILD_DIR))') \
	$(if $(LINUX_VERBOSE), V=1)
LINUX_MAKE_OLDCONFIG = yes '' | $(LINUX_MAKE) oldconfig >/dev/null

LINUX_MODULES = $(shell grep '^CONFIG_MODULES=y' $(LINUX_BUILD_CONFIG) 2>/dev/null)
LINUX_INITRAMFS = $(shell grep '^CONFIG_INITRAMFS_SOURCE=' $(LINUX_BUILD_CONFIG) 2>/dev/null)
LINUX_GET_INITRAMFS = sed -n 's,^CONFIG_INITRAMFS_SOURCE="*\(.*\)"*,\1,p' $(LINUX_BUILD_CONFIG)
LINUX_SET_INITRAMFS = sed -i 's,^\(CONFIG_INITRAMFS_SOURCE=\).*,\1"$(abspath $(ROOT_CPIO))",' $(LINUX_BUILD_CONFIG)

.PHONY : linux linux_clean linux_init linux_image_init linux_init2 \
	linux_modules linux_modules_install linux_initramfs linux_check_latest
clean : linux_clean

linux : linux_all

linux_init : $(TOOLCHAIN_DEP)
	@ printf '\n=== LINUX ===\n'
linux_image_init :
	@ printf '(end of part 1)\n\nmake root image for initramfs\n'
linux_init2 :
	@ printf '\n=== LINUX === (part 2)\n'

$(LINUX_SRC_DIR) :
	@ $(TOOLS_DIR)/init_src.sh '$(LINUX_DIR)' '$(LINUX_SRC)' '$@' '$(LINUX_PATCH_DIR)'

$(LINUX_BUILD_CONFIG) : | $(LINUX_SRC_DIR)
	mkdir -p $(@D)
	@ echo 'copy config to $@'
	@ if [ -f '$(strip $(LINUX_CONFIG))' ] ; then \
		cp $(LINUX_CONFIG) $@ ; \
	else \
		cp $(LINUX_DEFAULT_CONFIG) $@ ; \
	fi
	$(LINUX_MAKE_OLDCONFIG)

linux_initramfs : $(if $(LINUX_MODULES), linux_modules_install) linux_image_init image linux_init2
	@ if [ "`$(LINUX_GET_INITRAMFS)`" != '$(abspath $(ROOT_CPIO))' ] ; then \
		echo 'set CONFIG_INITRAMFS_SOURCE=$(ROOT_CPIO)' ; \
		$(LINUX_SET_INITRAMFS) && \
		$(LINUX_MAKE_OLDCONFIG) ; \
	fi

# wildcard rule
linux_% : linux_init $(LINUX_BUILD_CONFIG)
	$(if $(or \
			$(filter all, $*), \
			$(filter vmlinux, $*), \
			$(findstring Image, $*), \
			$(filter %-pkg, $*), \
			$(filter %rpm, $*), \
			$(filter %install, $*) \
		), \
		$(if $(LINUX_INITRAMFS), \
			$(MAKE) linux_initramfs, \
			$(if $(LINUX_MODULES), \
				$(MAKE) linux_modules_install \
			) \
		) \
	)
	$(LINUX_MAKE) $*

linux_modules : $(LINUX_BUILD_CONFIG)
	$(LINUX_MAKE) vmlinux
	$(LINUX_MAKE) modules

linux_modules_install : linux_modules
	rm -rf $(ROOT_BUILD_DIR)/lib/modules
	$(LINUX_MAKE) INSTALL_MOD_PATH=$(abspath $(ROOT_BUILD_DIR)) modules_install
	#find $(ROOT_BUILD_LIB_DIR)/modules -name "*.ko" | xargs -r $(TARGET_STRIP)

linux_firmware_install :
	$(LINUX_MAKE) INSTALL_MOD_PATH=$(abspath $(ROOT_BUILD_DIR)) firmware_install

linux_clean :
	- $(LINUX_MAKE) clean

linux_check_latest :
	@ $(call CHECK_LATEST_TARBALL, bz2, head, http://kernel.org)
