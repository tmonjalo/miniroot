# options can be set in config.mk
CROSSTOOL-NG_SRC ?= 1.4.2
CROSSTOOL-NG_PATCH_DIR ?= # [directory]

CROSSTOOL-NG_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

# if CROSSTOOL-NG_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(CROSSTOOL-NG_SRC)')),false)
override CROSSTOOL-NG_SRC := $(CROSSTOOL-NG_DIR)/crosstool-ng-$(strip $(CROSSTOOL-NG_SRC)).tar.bz2
CROSSTOOL-NG_URL = http://ymorin.is-a-geek.org/download/crosstool-ng/$(notdir $(CROSSTOOL-NG_SRC))
endif

CROSSTOOL-NG_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(CROSSTOOL-NG_DIR)' '$(CROSSTOOL-NG_SRC)')
CROSSTOOL-NG_BUILD_DIR = $(CROSSTOOL-NG_SRC_DIR)
CROSSTOOL-NG = $(CROSSTOOL-NG_BUILD_DIR)/ct-ng

.PHONY : crosstool-ng crosstool-ng_init crosstool-ng_clean crosstool-ng_check_latest

crosstool-ng : $(CROSSTOOL-NG)

crosstool-ng_init :
	@ printf '\n=== CROSSTOOL-NG ===\n'

$(CROSSTOOL-NG_SRC_DIR) :
	@ $(TOOLS_DIR)/init_src.sh '$(CROSSTOOL-NG_DIR)' '$(CROSSTOOL-NG_SRC)' '$(CROSSTOOL-NG_URL)' '$(CROSSTOOL-NG_PATCH_DIR)'

$(CROSSTOOL-NG_BUILD_DIR)/Makefile : | $(CROSSTOOL-NG_SRC_DIR)
	( set -e ; \
		cd $(CROSSTOOL-NG_BUILD_DIR) ; \
		./configure --local \
	)

$(CROSSTOOL-NG) : crosstool-ng_init $(CROSSTOOL-NG_BUILD_DIR)/Makefile
	$(MAKE) -C $(CROSSTOOL-NG_BUILD_DIR)

crosstool-ng_clean :
	- $(MAKE) -C $(CROSSTOOL-NG_BUILD_DIR) distclean

crosstool-ng_check_latest :
	@ $(call CHECK_LATEST_TARBALL, bz2, tail, http://ymorin.is-a-geek.org/download/crosstool-ng)
