PATCH_KERNEL = $(TOOLS_DIR)/patch-kernel.sh
MKLIBS = $(TOOLS_DIR)/mklibs.py
tools: $(PATCH_KERNEL) $(MKLIBS)

BUILDROOT_PATHS = \
	toolchain/patch-kernel.sh \
	toolchain/sstrip/sstrip.c \
	toolchain/mklibs/mklibs.py \
	target/makedevs/makedevs.c
BUILDROOT_URL_PREFIX = http://sources.busybox.net/index.py/trunk/buildroot/
BUILDROOT_URL_SUFFIX = ?view=co

define EXTERNAL_TOOLS_DOWNLOAD
$(1):
	wget -O $(1) $(2)
	 if [ '$(strip $(3))' = '.sh' -o '$(strip $(3))' = '.py' ] ; then \
		chmod +x $(1) ; \
	fi
endef
$(foreach PATH, $(BUILDROOT_PATHS), $(eval $(call EXTERNAL_TOOLS_DOWNLOAD, \
	$(TOOLS_DIR)/$(notdir $(PATH)), \
	$(BUILDROOT_URL_PREFIX)$(PATH)$(BUILDROOT_URL_SUFFIX), \
	$(suffix $(PATH)) \
)))

TOOLS_SRCS = $(foreach PATH, $(BUILDROOT_PATHS), $(TOOLS_DIR)/$(notdir $(PATH)))

.PHONY: external_tools_update external_tools_remove

external_tools_update: external_tools_remove $(TOOLS_SRCS)

external_tools_remove:
	- rm -f $(TOOLS_SRCS)
