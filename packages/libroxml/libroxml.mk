# options can be set in config.mk
PKG_LIBROXML ?= no
LIBROXML_SRC ?= 1.5
LIBROXML_PATCH_DIR ?= # [directory]
#LIBROXML_BUILD_INSIDE = no
#LIBROXML_VERBOSE = no

LIBROXML_DEPS =

LIBROXML_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

# if LIBROXML_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(LIBROXML_SRC)')),false)
override LIBROXML_SRC := $(LIBROXML_DIR)/libroxml-$(strip $(LIBROXML_SRC)).tar.gz
LIBROXML_URL = http://libroxml.googlecode.com/files/$(notdir $(LIBROXML_SRC))
endif

LIBROXML_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(LIBROXML_DIR)' '$(LIBROXML_SRC)')
LIBROXML_BUILD_DIR = $(if $(LIBROXML_BUILD_INSIDE), $(LIBROXML_SRC_DIR), $(BUILD_DIR)/$(notdir $(LIBROXML_SRC_DIR)))
LIBROXML_BUILD_BIN = $(LIBROXML_BUILD_DIR)/roxml
LIBROXML_INSTALL_BIN = $(ROOT_BUILD_DIR)/bin/$(notdir $(LIBROXML_BUILD_BIN))

.PHONY: libroxml libroxml_init libroxml_clean
$(eval $(call PKG_INCLUDE_RULE, $(PKG_LIBROXML), libroxml))

libroxml: $(LIBROXML_DEPS) $(LIBROXML_INSTALL_BIN)

libroxml_init:
	@ echo '=== LIBROXML ==='
	@ $(TOOLS_DIR)/init_src.sh '$(LIBROXML_DIR)' '$(LIBROXML_SRC)' '$(LIBROXML_URL)' '$(LIBROXML_PATCH_DIR)'

$(LIBROXML_BUILD_BIN): libroxml_init
	$(SET_PATH) $(MAKE) -C $(LIBROXML_SRC_DIR) $(abspath $(LIBROXML_BUILD_BIN)) \
		$(if $(LIBROXML_BUILD_INSIDE), , O='$(abspath $(LIBROXML_BUILD_DIR))') \
		$(if $(LIBROXML_VERBOSE), V=1) \
		$(SET_CC) $(SET_CPPFLAGS) $(SET_CFLAGS) $(SET_LDFLAGS)

$(LIBROXML_INSTALL_BIN): $(LIBROXML_BUILD_BIN)
	install -D $(LIBROXML_BUILD_BIN) $(LIBROXML_INSTALL_BIN)

libroxml_clean:
	- $(MAKE) -C $(LIBROXML_SRC_DIR) clean \
		$(if $(LIBROXML_BUILD_INSIDE), , O='$(abspath $(LIBROXML_BUILD_DIR))')
