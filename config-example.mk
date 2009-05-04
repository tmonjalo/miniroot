# Main targets
TARGETS = linux_uImage

# Host compilation

# Target compilation
TARGET_ARCH = arm
TOOLCHAIN_PATH = /home/me/toolchain-arm-uclibc
TOOLCHAIN_PREFIX = arm-linux-uclibc-
TARGET_CC = 'ccache $(TOOLCHAIN_PATH)/bin/$(TOOLCHAIN_PREFIX)gcc'

# Linux
LINUX_CONFIG = arm_defconfig

# Root filesystem

# Busybox

# Packages
PKG_DROPBEAR_SERVER = yes
