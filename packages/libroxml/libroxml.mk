# options can be set in config.mk
LIBROXML_SRC ?= 1.4
#LIBROXML_PATCH_DIR = [directory]
#LIBROXML_BUILD_INSIDE = no

LIBROXML_DEPS =

# if LIBROXML_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(LIBROXML_SRC)')),false)
override LIBROXML_SRC := $(LIBROXML_DIR)/libroxml-$(strip $(LIBROXML_SRC)).tar.gz
LIBROXML_URL = http://libroxml.googlecode.com/files/$(notdir $(LIBROXML_SRC))
endif

LIBROXML_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(LIBROXML_DIR)' '$(LIBROXML_SRC)')
LIBROXML_BUILD_DIR = $(if $(LIBROXML_BUILD_INSIDE), $(LIBROXML_SRC_DIR), $(BUILD_DIR)/$(notdir $(LIBROXML_DIR)))
LIBROXML_BUILD_BIN = $(LIBROXML_BUILD_DIR)/roxml
LIBROXML_INSTALL_BIN = $(ROOT_BUILD_DIR)/bin/$(notdir $(LIBROXML_BUILD_BIN))

.PHONY: libroxml libroxml_init libroxml_clean
$(eval $(call PKG_INCLUDE_RULE, $(PKG_LIBROXML), libroxml))

libroxml: $(LIBROXML_DEPS) $(LIBROXML_INSTALL_BIN)

libroxml_init:
	@ echo '=== LIBROXML ==='
	@ $(TOOLS_DIR)/init_src.sh '$(LIBROXML_DIR)' '$(LIBROXML_SRC)' '$(LIBROXML_URL)' '$(LIBROXML_PATCH_DIR)'

$(LIBROXML_BUILD_BIN): libroxml_init
	$(SET_CROSS_PATH) $(MAKE) -C $(LIBROXML_SRC_DIR) $(abspath $@) \
		$(if $(LIBROXML_BUILD_INSIDE), , O='$(abspath $(LIBROXML_BUILD_DIR))') \
		$(SET_CROSS_CC) $(SET_CFLAGS) $(SET_LDFLAGS)

$(LIBROXML_INSTALL_BIN): $(LIBROXML_BUILD_BIN)
	install -D $< $@

libroxml_clean:
	$(MAKE) -C $(LIBROXML_SRC_DIR) clean \
		$(if $(LIBROXML_BUILD_INSIDE), , O='$(abspath $(LIBROXML_BUILD_DIR))')
