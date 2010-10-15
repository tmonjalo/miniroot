SSTRIP_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
SSTRIP_SRC := $(SRC_DIR)/tools/sstrip.c
SSTRIP := $(HOST_BUILD_DIR)/sstrip

.PHONY : sstrip_clean
tools : $(SSTRIP)
tools_clean : sstrip_clean

$(SSTRIP) : $(SSTRIP_SRC) | $(dir $(SSTRIP))
	$(HOST_CC) $< -o $@

sstrip_clean :
	- rm -rf $(SSTRIP_BUILD_DIR)
