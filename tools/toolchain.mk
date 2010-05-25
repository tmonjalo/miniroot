HOST_CC ?= gcc
#TARGET_ARCH =
#TOOLCHAIN_PATH =
TOOLCHAIN_PREFIX ?= $(if $(TARGET_ARCH), $(TARGET_ARCH)-unknown-linux-gnu-)
TARGET_CC ?= ccache $(notdir $(TOOLCHAIN_CC))
TARGET_CXX ?= $(patsubst %g,%,$(TARGET_CC:gcc=))g++

TOOLCHAIN_PATH_PREFIX = $(if $(TOOLCHAIN_PATH), $(strip $(TOOLCHAIN_PATH))/bin/$(strip $(TOOLCHAIN_PREFIX)))
TOOLCHAIN_CC = $(TOOLCHAIN_PATH_PREFIX)gcc

ifneq '$(TARGET_ARCH)' ''        # if ARCH defined
ifeq '$(TOOLCHAIN_PATH)' ''      # and PATH undefined
TOOLCHAIN_DEP = $(TOOLCHAIN_CC)  # then build the toolchain
TOOLCHAIN_PATH = $(TOOLCHAIN_BUILD_DIR)/toolchain
tools : toolchain
clean : toolchain_clean crosstool-ng_clean
endif
endif

TARGET_LIB_DIRS += $(if $(TOOLCHAIN_PATH), $(strip $(TOOLCHAIN_PATH))/lib)

include $(TOOLS_DIR)/toolchain/crosstool-ng.mk

TOOLCHAIN_BUILD_DIR := $(BUILD_DIR)/$(TOOLCHAIN_PREFIX:-=)
TOOLCHAIN_BUILD_CONFIG := $(TOOLCHAIN_BUILD_DIR)/.config
TOOLCHAIN_DEFAULT_CONFIG = $(CROSSTOOL-NG_SRC_DIR)/samples/$(TOOLCHAIN_PREFIX:-=)/crosstool.config

TOOLCHAIN_MAKE = $(abspath $(CROSSTOOL-NG)) -C $(TOOLCHAIN_BUILD_DIR)
TOOLCHAIN_MAKE_OLDCONFIG = yes '' | $(TOOLCHAIN_MAKE) oldconfig >/dev/null

TOOLCHAIN_CONFIG_SET = sed -i 's,^\($(strip $1)\).*,\1="$(strip $2)",' $(TOOLCHAIN_BUILD_CONFIG)
TOOLCHAIN_CONFIG_ENABLE = sed -i '/^$(strip $1).*/d' $(TOOLCHAIN_BUILD_CONFIG) && echo $(strip $1)=y >> $(TOOLCHAIN_BUILD_CONFIG)
TOOLCHAIN_CONFIG_DISABLE = sed -i 's,^\($(strip $1)\).*,\# \1 is not set,' $(TOOLCHAIN_BUILD_CONFIG)

.PHONY : toolchain toolchain_init toolchain_clean

toolchain : $(TOOLCHAIN_DEP)

$(TOOLCHAIN_CC) :
	@ $(MAKE) --no-print-directory toolchain_build

toolchain_init :
	@ printf '\n=== TOOLCHAIN ===\n'

$(TOOLCHAIN_BUILD_CONFIG) :
	mkdir -p $(@D)
	@ echo 'copy config to $@'
	@ if [ -f '$(strip $(TOOLCHAIN_CONFIG))' ] ; then \
		cp $(TOOLCHAIN_CONFIG) $@ ; \
	else \
		cp $(TOOLCHAIN_DEFAULT_CONFIG) $@ ; \
	fi
	$(call TOOLCHAIN_CONFIG_SET,     CT_LOCAL_TARBALLS_DIR     , $(abspath $(DL_DIR)))
	$(call TOOLCHAIN_CONFIG_ENABLE,  CT_SAVE_TARBALLS          )
	$(call TOOLCHAIN_CONFIG_SET,     CT_WORK_DIR               , $${CT_TOP_DIR}/tmp)
	$(call TOOLCHAIN_CONFIG_SET,     CT_PREFIX_DIR             , $${CT_TOP_DIR}/toolchain)
	$(if $(TOOLCHAIN_UCLIBC_CONFIG), \
	$(call TOOLCHAIN_CONFIG_SET,     CT_LIBC_UCLIBC_CONFIG_FILE, $(abspath $(TOOLCHAIN_UCLIBC_CONFIG))))
	$(TOOLCHAIN_MAKE_OLDCONFIG)

toolchain_% : $(CROSSTOOL-NG) toolchain_init $(TOOLCHAIN_BUILD_CONFIG)
	$(TOOLCHAIN_MAKE) $*

toolchain_clean :
	- chmod -R +w $(TOOLCHAIN_BUILD_DIR)
	- rm -rf $(TOOLCHAIN_BUILD_DIR)
