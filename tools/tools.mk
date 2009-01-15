.PHONY: tools tools_clean
clean: tools_clean

include $(TOOLS_DIR)/toolchain.mk
include $(TOOLS_DIR)/external_tools.mk
include $(TOOLS_DIR)/sstrip.mk
include $(TOOLS_DIR)/makedevs.mk
