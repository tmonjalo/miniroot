CROSSTOOL-NG_SRC ?= 1.4.2
CROSSTOOL-NG_PATCH_DIR ?=
CROSSTOOL-NG_SRC_DIR ?= $(CROSSTOOL-NG_SRC_AUTODIR)

CROSSTOOL-NG_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

CROSSTOOL-NG_URL = http://ymorin.is-a-geek.org/download/crosstool-ng
# if CROSSTOOL-NG_SRC is a version number
ifeq '$(call IS_SRC, $(CROSSTOOL-NG_SRC))' ''
override CROSSTOOL-NG_SRC := $(CROSSTOOL-NG_URL)/crosstool-ng-$(strip $(CROSSTOOL-NG_SRC)).tar.bz2
endif

CROSSTOOL-NG_SRC_AUTODIR := $(shell $(TOOLS_DIR)/get_src_dir.sh '$(BUILD_DIR)' '$(CROSSTOOL-NG_SRC)')
CROSSTOOL-NG_BUILD_DIR := $(CROSSTOOL-NG_SRC_DIR)
CROSSTOOL-NG_BUILD_MAKEFILE := $(CROSSTOOL-NG_BUILD_DIR)/Makefile
CROSSTOOL-NG := $(CROSSTOOL-NG_BUILD_DIR)/ct-ng

CROSSTOOL-NG_MAKE = $(MAKE) -C $(CROSSTOOL-NG_BUILD_DIR)

.PHONY : crosstool-ng crosstool-ng_init crosstool-ng_clean crosstool-ng_check_latest
check_latest : crosstool-ng_check_latest

crosstool-ng : $(CROSSTOOL-NG)

crosstool-ng_init :
	@ printf '\n=== CROSSTOOL-NG ===\n'

$(CROSSTOOL-NG_SRC_DIR) :
	@ $(TOOLS_DIR)/init_src.sh '$(CROSSTOOL-NG_DIR)' '$(CROSSTOOL-NG_SRC)' '$@' '$(CROSSTOOL-NG_PATCH_DIR)'

$(CROSSTOOL-NG_BUILD_MAKEFILE) : | $(CROSSTOOL-NG_SRC_DIR)
	cd $(@D) && ./configure --local

$(CROSSTOOL-NG) : crosstool-ng_init $(CROSSTOOL-NG_BUILD_MAKEFILE)
	$(CROSSTOOL-NG_MAKE)

crosstool-ng_% :
	$(CROSSTOOL-NG_MAKE) $*

crosstool-ng_clean :
	- $(CROSSTOOL-NG_MAKE) distclean

crosstool-ng_check_latest :
	@ $(call CHECK_LATEST_ARCHIVE, tail, $(CROSSTOOL-NG_URL))
