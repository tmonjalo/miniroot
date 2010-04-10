include $(TOOLS_DIR)/sstrip.mk

include $(TOOLS_DIR)/makedevs.mk

PATCH_KERNEL := $(TOOLS_DIR)/patch-kernel.sh
tools : $(PATCH_KERNEL)

MKLIBS := $(TOOLS_DIR)/mklibs.py
tools : $(MKLIBS)

BUILDROOT_URL = http://git.buildroot.net/buildroot/plain
BUILDROOT_PATHS = \
	toolchain/patch-kernel.sh \
	toolchain/sstrip/sstrip.c \
	toolchain/mklibs/mklibs.py \
	package/makedevs/makedevs.c

define EXTERNAL_TOOLS_DOWNLOAD
$1 :
	cd $(dir $1) && wget $2
	if [ '$(strip $3)' = '.sh' -o '$(strip $3)' = '.py' ] ; then \
		chmod +x $1 ; \
	fi
endef
$(foreach PATH, $(BUILDROOT_PATHS), $(eval $(call EXTERNAL_TOOLS_DOWNLOAD, \
	$(TOOLS_DIR)/$(notdir $(PATH)), \
	$(BUILDROOT_URL)/$(PATH), \
	$(suffix $(PATH)) \
)))

TOOLS_SRCS = $(foreach PATH, $(BUILDROOT_PATHS), $(TOOLS_DIR)/$(notdir $(PATH)))

.PHONY : external_tools_update external_tools_remove

external_tools_update : external_tools_remove $(TOOLS_SRCS)

external_tools_remove :
	- rm -f $(TOOLS_SRCS)
