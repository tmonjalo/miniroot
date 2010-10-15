IMAGE_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
IMAGE_BUILD_DIR := $(TARGET_BUILD_DIR)/$(IMAGE_DIR)

FAKEROOT_SCRIPT := $(IMAGE_BUILD_DIR)/fakeroot.sh

ROOT_CPIO := $(IMAGE_BUILD_DIR)/$(if $(LINUX_INITRAMFS),root.cpio,root.gz)
ROOT_CPIO_BUILD = cd $(ROOT_BUILD_DIR) && find | cpio --quiet --create --format=newc $(if $(LINUX_INITRAMFS),,| gzip --best)

.PHONY : image image_init image_clean
clean : image_clean

image : root $(ROOT_CPIO)

image_init :
	@ printf '\n=== IMAGE ===\n'

$(IMAGE_BUILD_DIR) :
	mkdir -p $@

$(ROOT_CPIO) : root_dev image_init | $(IMAGE_BUILD_DIR)
	echo '$(ROOT_CPIO_BUILD) > $(abspath $@)' >> $(FAKEROOT_SCRIPT)
	fakeroot sh -x $(FAKEROOT_SCRIPT)
	@ echo "image: `du --human-readable $@`"

image_clean :
	- rm -rf $(IMAGE_BUILD_DIR)
