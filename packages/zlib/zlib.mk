# options can be set in config.mk
ZLIB_SRC ?= 1.2.3
ZLIB_PATCH_DIR ?= # [directory]
ZLIB_BUILD_INSIDE = yes # cannot build zlib outside

ZLIB_DEPS =

# if ZLIB_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(ZLIB_SRC)')),false)
override ZLIB_SRC := $(ZLIB_DIR)/zlib-$(strip $(ZLIB_SRC)).tar.bz2
ZLIB_URL = http://www.zlib.net/$(notdir $(ZLIB_SRC))
endif

ZLIB_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(ZLIB_DIR)' '$(ZLIB_SRC)')
ZLIB_VERSION = $(shell sed -n 's,.*VERSION.*"\(.*\)".*,\1,p' $(ZLIB_SRC_DIR)/zlib.h 2>/dev/null)
ZLIB_BUILD_DIR = $(if $(ZLIB_BUILD_INSIDE), $(ZLIB_SRC_DIR), $(BUILD_DIR)/$(notdir $(ZLIB_DIR)))
ZLIB_BUILD_BIN = $(ZLIB_BUILD_DIR)/libz.$(if $(TARGET_STATIC),a,so.$(ZLIB_VERSION))

.PHONY: zlib zlib_init zlib_configure zlib_clean
$(eval $(call PKG_INCLUDE_RULE, $(PKG_ZLIB), zlib))

zlib: $(ZLIB_DEPS) $(ZLIB_BUILD_BIN)

zlib_init:
	@ echo '=== ZLIB ==='
	@ $(TOOLS_DIR)/init_src.sh '$(ZLIB_DIR)' '$(ZLIB_SRC)' '$(ZLIB_URL)' '$(ZLIB_PATCH_DIR)'

zlib_configure:
	( cd $(ZLIB_BUILD_DIR) && \
		$(SET_PATH) $(SET_CC) CFLAGS='$(TARGET_CFLAGS) -fPIC' $(SET_LDFLAGS) \
		$(if $(TARGET_STATIC), ./configure, ./configure --shared) \
	)

$(ZLIB_BUILD_BIN): zlib_init
	@ if ! fgrep -q 'LIBS=$(notdir $(ZLIB_BUILD_BIN))' $(ZLIB_SRC_DIR)/Makefile ; then \
		$(MAKE) zlib_configure ; \
	fi
	$(SET_PATH) $(MAKE) -C $(ZLIB_BUILD_DIR) $(notdir $(ZLIB_BUILD_BIN))

zlib_clean:
	- $(MAKE) -C $(ZLIB_BUILD_DIR) clean

TARGET_LIB_DIRS += $(ZLIB_BUILD_DIR)
