BUSYBOX_SRC ?= 1.14.3
BUSYBOX_PATCH_DIR ?=
BUSYBOX_CONFIG ?=
BUSYBOX_DL_DIR ?= $(DL_DIR)
BUSYBOX_SRC_DIR ?= $(BUSYBOX_SRC_AUTODIR)
#BUSYBOX_BUILD_INSIDE = no
#BUSYBOX_VERBOSE = no

BUSYBOX_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

BUSYBOX_URL = http://busybox.net/downloads
# if BUSYBOX_SRC is a version number
ifeq '$(call IS_SRC, $(BUSYBOX_SRC))' ''
override BUSYBOX_SRC := $(BUSYBOX_URL)/busybox-$(strip $(BUSYBOX_SRC)).tar.bz2
endif

BUSYBOX_SRC_AUTODIR := $(shell $(TOOLS_DIR)/get_src_dir.sh '$(SRC_DIR)' '$(BUSYBOX_SRC)')
BUSYBOX_BUILD_DIR := $(if $(BUSYBOX_BUILD_INSIDE), $(BUSYBOX_SRC_DIR), $(BUILD_DIR)/$(notdir $(BUSYBOX_SRC_DIR)))
BUSYBOX_BUILD_CONFIG := $(BUSYBOX_BUILD_DIR)/.config
BUSYBOX_DEFAULT_CONFIG = $(BUSYBOX_DIR)/default_config
BUSYBOX_BUILD_BIN := $(BUSYBOX_BUILD_DIR)/busybox
BUSYBOX_INSTALL_BIN := $(ROOT_BUILD_DIR)/bin/busybox

BUSYBOX_MAKE = $(SET_PATH) $(MAKE) -C $(BUSYBOX_SRC_DIR) \
	$(SET_CROSS_COMPILE) $(SET_CC) $(SET_EXTRA_CFLAGS) $(SET_EXTRA_LDFLAGS) \
	$(if $(BUSYBOX_BUILD_INSIDE), , O='$(abspath $(BUSYBOX_BUILD_DIR))') \
	$(if $(BUSYBOX_VERBOSE), V=1) \
	CONFIG_PREFIX='$(abspath $(ROOT_BUILD_DIR))'
BUSYBOX_MAKE_OLDCONFIG = yes '' | $(BUSYBOX_MAKE) oldconfig >/dev/null

.PHONY : busybox busybox_init busybox_clean busybox_check_latest
clean : busybox_clean
check_latest : busybox_check_latest

busybox : $(BUSYBOX_INSTALL_BIN)

busybox_init : $(TOOLCHAIN_DEP)
	@ printf '\n=== BUSYBOX ===\n'

$(BUSYBOX_SRC_DIR) :
	@ $(TOOLS_DIR)/init_src.sh '$(BUSYBOX_SRC)' '$(BUSYBOX_DL_DIR)' '$@' '$(BUSYBOX_PATCH_DIR)'

$(BUSYBOX_BUILD_CONFIG) : | $(BUSYBOX_SRC_DIR)
	mkdir -p $(@D)
	@ echo 'copy config to $@'
	@ if [ -f '$(strip $(BUSYBOX_CONFIG))' ] ; then \
		cp $(BUSYBOX_CONFIG) $@ ; \
	else \
		cp $(BUSYBOX_DEFAULT_CONFIG) $@ ; \
	fi
	$(BUSYBOX_MAKE_OLDCONFIG)

# wildcard rule
busybox_% : busybox_init $(BUSYBOX_BUILD_CONFIG)
	$(BUSYBOX_MAKE) $*

$(BUSYBOX_BUILD_BIN) : busybox_busybox
	@ : # nop rule to make install working

$(BUSYBOX_INSTALL_BIN) : $(BUSYBOX_BUILD_BIN)
	$(BUSYBOX_MAKE) install
	chmod 4755 $@

busybox_clean :
	- $(BUSYBOX_MAKE) clean uninstall

busybox_check_latest :
	@ $(call CHECK_LATEST_ARCHIVE, head, http://busybox.net)
