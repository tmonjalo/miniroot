PKG_BUILD_DIR = $(BUILD_DIR)

.PHONY: packages packages_clean
clean: packages_clean

define PKG_IS_SET
$(strip $(or \
	$(findstring y, $(1)), \
	$(findstring Y, $(1)), \
))
endef

define PKG_INCLUDE_RULE
ifneq ($(call PKG_IS_SET, $(1)),)
packages: $(2)
packages_clean: $(2)_clean
endif
endef

DROPBEAR_DIR = $(PKG_DIR)/dropbear
include $(DROPBEAR_DIR)/dropbear.mk
