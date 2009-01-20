# options can be set in config.mk
ZLIB_SRC ?= 1.2.3
ZLIB_PATCH_DIR =
ZLIB_BUILD_INSIDE = yes # cannot build zlib outside

# if ZLIB_SRC is a version number
ifeq ($(strip $(shell $(TOOLS_DIR)/is_src.sh '$(ZLIB_DIR)' '$(ZLIB_SRC)')),false)
override ZLIB_SRC := zlib-$(strip $(ZLIB_SRC)).tar.bz2
ZLIB_URL = http://www.zlib.net/$(ZLIB_SRC)
endif

ZLIB_SRC_DIR = $(shell $(TOOLS_DIR)/get_src_dir.sh '$(ZLIB_DIR)' '$(ZLIB_SRC)')
ZLIB_VERSION = $(shell sed -n 's,.*VERSION.*"\(.*\)".*,\1,p' $(ZLIB_SRC_DIR)/zlib.h 2>/dev/null)
ZLIB_BUILD_DIR = $(ZLIB_SRC_DIR)
ZLIB_BUILD_BIN = $(ZLIB_BUILD_DIR)/libz.so.$(ZLIB_VERSION)
ZLIB_INSTALL_BIN = $(ROOT_BUILD_LIB_DIR)/$(notdir $(ZLIB_BUILD_BIN))

.PHONY: zlib zlib_init zlib_configure zlib_clean
$(eval $(call PKG_INCLUDE_RULE, $(PKG_ZLIB), zlib))

zlib: $(ZLIB_INSTALL_BIN)

zlib_init:
	@ echo '=== ZLIB ==='
	@ $(TOOLS_DIR)/init_src.sh '$(ZLIB_DIR)' '$(ZLIB_SRC)' '$(ZLIB_URL)' '$(ZLIB_PATCH_DIR)'
	@ if fgrep -q 'LIBS=libz.a' $(ZLIB_SRC_DIR)/Makefile ; then \
		$(MAKE) zlib_configure ; \
	fi

zlib_configure:
	( cd $(ZLIB_BUILD_DIR) && \
	$(SET_CROSS_PATH) $(SET_CROSS_CC) CFLAGS='$(CROSS_CFLAGS) -fPIC' ./configure --shared )

$(ZLIB_BUILD_BIN): zlib_init
	$(SET_CROSS_PATH) $(MAKE) -C $(ZLIB_BUILD_DIR) $(notdir $@)

$(ZLIB_INSTALL_BIN): $(ZLIB_BUILD_BIN)
	install -D $(ZLIB_BUILD_BIN) $@
	$(CROSS_STRIP) $@
	find $(ZLIB_BUILD_DIR) -type l -name "lib*" -exec cp -P '{}' $(ROOT_BUILD_LIB_DIR) \;

zlib_clean:
	- $(MAKE) -C $(ZLIB_BUILD_DIR) clean
	- rm -f $(ZLIB_INSTALL_BIN)