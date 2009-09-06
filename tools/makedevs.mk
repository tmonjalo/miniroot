MAKEDEVS_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
MAKEDEVS_SRC := $(MAKEDEVS_DIR)/makedevs.c
MAKEDEVS := $(TOOLS_BUILD_DIR)/makedevs

.PHONY : makedevs_clean
tools : $(MAKEDEVS)
tools_clean : makedevs_clean

$(MAKEDEVS) : $(MAKEDEVS_SRC) | $(dir $(MAKEDEVS))
	$(HOST_CC) -Wall -Werror -O2 $< -o $@

makedevs_clean :
	- rm -rf $(MAKEDEVS_BUILD_DIR)
