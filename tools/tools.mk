TOOLS_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
TOOLS_BUILD_DIR := $(BUILD_DIR)/$(TOOLS_DIR)

.PHONY : tools tools_clean
clean : tools_clean

$(TOOLS_BUILD_DIR) :
	mkdir -p $@

include $(TOOLS_DIR)/common.mk

include $(TOOLS_DIR)/toolchain.mk

include $(TOOLS_DIR)/external_tools.mk

include $(TOOLS_DIR)/check_latest.mk

# query variable value (not expanded)
%?? :
	@ $(if $(filter undefined, $(origin $*)), \
		echo '$* undefined' >&2, \
		echo '$* = $(value $*)' \
	)
# query expanded variable value
%? :
	@ $(if $(filter undefined, $(origin $*)), \
		echo '$* undefined' >&2, \
		echo '$* = $($*)' \
	)
