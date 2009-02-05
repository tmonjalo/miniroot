IMAGE_BUILD_DIR = $(BUILD_DIR)/$(IMAGE_DIR)
FAKEROOT_SCRIPT = $(IMAGE_BUILD_DIR)/fakeroot.sh
ROOT_CPIO = $(IMAGE_BUILD_DIR)/$(if $(LINUX_INITRAMFS),root.cpio,root.gz)

.PHONY: image image_init image_clean
clean: image_clean

image: root $(ROOT_CPIO)

image_init:
	@ echo '=== IMAGE ==='
	mkdir -p $(IMAGE_BUILD_DIR)

$(ROOT_CPIO): root_dev image_init
	echo 'cd $(ROOT_BUILD_DIR) && find \
		| cpio --quiet --create --format=newc \
		$(if $(LINUX_INITRAMFS),,| gzip --best) \
		> $(abspath $@)' \
	>> $(FAKEROOT_SCRIPT)
	fakeroot sh -x $(FAKEROOT_SCRIPT)
	@ echo "image: `du --human-readable $@`"

image_clean:
	- rm -rf $(IMAGE_BUILD_DIR)
