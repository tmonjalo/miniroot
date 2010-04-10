PKG_LIBROXML ?= no
LIBROXML_SRC ?= 2.0.1
LIBROXML_PATCH_DIR ?=
LIBROXML_DL_DIR ?= $(DL_DIR)
LIBROXML_SRC_DIR ?= $(LIBROXML_SRC_AUTODIR)
#LIBROXML_BUILD_INSIDE = no
#LIBROXML_VERBOSE = no

LIBROXML_DEPS =

LIBROXML_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

LIBROXML_URL = http://libroxml.googlecode.com/files
# if LIBROXML_SRC is a version number
ifeq '$(call IS_SRC, $(LIBROXML_SRC))' ''
override LIBROXML_SRC := $(LIBROXML_URL)/libroxml-$(strip $(LIBROXML_SRC)).tar.gz
endif

LIBROXML_SRC_AUTODIR := $(shell $(TOOLS_DIR)/get_src_dir.sh '$(SRC_DIR)' '$(LIBROXML_SRC)')
LIBROXML_BUILD_DIR := $(if $(LIBROXML_BUILD_INSIDE), $(LIBROXML_SRC_DIR), $(BUILD_DIR)/$(notdir $(LIBROXML_SRC_DIR)))
LIBROXML_BUILD_BIN := $(LIBROXML_BUILD_DIR)/roxml
LIBROXML_INSTALL_BIN := $(ROOT_BUILD_DIR)/bin/$(notdir $(LIBROXML_BUILD_BIN))

.PHONY : libroxml libroxml_init libroxml_clean libroxml_check_latest
$(eval $(call PKG_INCLUDE_RULE, $(PKG_LIBROXML), libroxml))

libroxml : $(LIBROXML_DEPS) $(LIBROXML_INSTALL_BIN)

libroxml_init : $(TOOLCHAIN_DEP)
	@ printf '\n=== LIBROXML ===\n'

$(LIBROXML_SRC_DIR) :
	@ $(TOOLS_DIR)/init_src.sh '$(LIBROXML_SRC)' '$(LIBROXML_DL_DIR)' '$@' '$(LIBROXML_PATCH_DIR)'

$(LIBROXML_BUILD_BIN) : libroxml_init | $(LIBROXML_SRC_DIR)
	$(SET_PATH) $(MAKE) -C $| $(abspath $@) \
		$(if $(LIBROXML_BUILD_INSIDE), , O='$(abspath $(@D))') \
		$(if $(LIBROXML_VERBOSE), V=1) \
		$(SET_CC) $(SET_CPPFLAGS) $(SET_CFLAGS) $(SET_LDFLAGS)

$(LIBROXML_INSTALL_BIN) : $(LIBROXML_BUILD_BIN)
	install -D $< $@

libroxml_clean :
	- $(MAKE) -C $(LIBROXML_SRC_DIR) clean \
		$(if $(LIBROXML_BUILD_INSIDE), , O='$(abspath $(LIBROXML_BUILD_DIR))')

libroxml_check_latest :
	@ $(call CHECK_LATEST_ARCHIVE, head, http://code.google.com/p/libroxml/downloads/list)
