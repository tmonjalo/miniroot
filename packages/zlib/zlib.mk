ZLIB_SRC ?= 1.2.4
ZLIB_PATCH_DIR ?=
ZLIB_DL_DIR ?= $(DL_DIR)
ZLIB_SRC_DIR ?= $(ZLIB_SRC_AUTODIR)
ZLIB_BUILD_INSIDE = yes # cannot build zlib outside

ZLIB_DEPS =

ZLIB_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

ZLIB_URL = http://zlib.net
# if ZLIB_SRC is a version number
ifeq '$(call IS_SRC, $(ZLIB_SRC))' ''
override ZLIB_SRC := $(ZLIB_URL)/zlib-$(strip $(ZLIB_SRC)).tar.bz2
endif

ZLIB_SRC_AUTODIR := $(shell $(TOOLS_DIR)/get_src_dir.sh '$(SRC_DIR)' '$(ZLIB_SRC)')
ZLIB_VERSION = $(shell sed -n 's,.*VERSION.*"\(.*\)".*,\1,p' $(ZLIB_SRC_DIR)/zlib.h 2>&-)
ZLIB_BUILD_DIR := $(if $(ZLIB_BUILD_INSIDE), $(ZLIB_SRC_DIR), $(BUILD_DIR)/$(notdir $(ZLIB_SRC_DIR)))
ZLIB_BUILD_BIN := $(ZLIB_BUILD_DIR)/libz.$(if $(TARGET_STATIC),a,so.$(ZLIB_VERSION))

TARGET_LIB_DIRS += $(ZLIB_BUILD_DIR)

.PHONY : zlib zlib_init zlib_configure zlib_clean zlib_check_latest
$(eval $(call PKG_INCLUDE_RULE, $(PKG_ZLIB), zlib))

zlib : $(ZLIB_DEPS) $(ZLIB_BUILD_BIN)

zlib_init : $(TOOLCHAIN_DEP)
	@ printf '\n=== ZLIB ===\n'

$(ZLIB_SRC_DIR) :
	@ $(TOOLS_DIR)/init_src.sh '$(ZLIB_SRC)' '$(ZLIB_DL_DIR)' '$@' '$(ZLIB_PATCH_DIR)'

zlib_configure : | $(ZLIB_SRC_DIR)
	cd $(ZLIB_BUILD_DIR) && \
		$(SET_PATH) $(SET_CC) CFLAGS='$(TARGET_CFLAGS) -fPIC' $(SET_LDFLAGS) \
		$(if $(TARGET_STATIC), ./configure, ./configure --shared)

$(ZLIB_BUILD_BIN) : zlib_init
	@ if ! fgrep -q 'LIBS=$(@F)' $(ZLIB_SRC_DIR)/Makefile ; then \
		$(MAKE) zlib_configure ; \
	fi
	$(SET_PATH) $(MAKE) -C $(@D) $(@F)

zlib_clean :
	- $(MAKE) -C $(ZLIB_BUILD_DIR) clean

zlib_check_latest :
	@ $(call CHECK_LATEST_ARCHIVE, head, $(ZLIB_URL))
