# Main targets
TARGETS = linux_uImage

# Host compilation

# Target compilation
TARGET_ARCH = arm
TOOLCHAIN_PATH = /home/me/toolchain-arm-uclibc
TOOLCHAIN_PREFIX = arm-linux-uclibc-

# Linux
LINUX_CONFIG = arm_defconfig

# Root filesystem

# Busybox

# Packages
PKG_DROPBEAR_SERVER = yes
