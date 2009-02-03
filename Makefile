all:

# Default configuration
include config-default.mk

# Overwrite default configuration with user parameters
include config.mk

# All rules
include all.mk

# Add user-defined rules which can use variables from all.mk
ifdef EXTRA_RULES
include $(EXTRA_RULES)
endif
