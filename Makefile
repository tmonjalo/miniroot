#########################################################################
#
# Very simple Makefile to build a very simple userspace.
#
#########################################################################

#
# Some paths
#
BUILD_DIR:=$(PWD)
MAKEDEVS_DIR:=$(BUILD_DIR)/makedevs
BUSYBOX_DIR:=$(BUILD_DIR)/busybox
IMAGE_DIR:=$(BUILD_DIR)/image
ROOTFS_DIR:=$(IMAGE_DIR)/rootfs
ROOTFS_SKEL_DIR:=$(IMAGE_DIR)/rootfs_skel
#
# Host compilation flags
#
HOSTCC:=gcc
#
# Generic cross-compilation flags
#
CROSS_PATH:=/opt/arm-uclibc-0.9.28-3
CROSS_PREFIX:=arm-linux-uclibc-
CROSS_CC:=$(CROSS_PATH)/bin/$(CROSS_PREFIX)gcc
CROSS_CPPFLAGS:= -I$(CROSS_PATH)/include
CROSS_CFLAGS:= -Os -static $(CROSS_CPPFLAGS)
CROSS_LDFLAGS:= -Os -static -L$(CROSS_PATH)/lib
#
# Options
#
STRIPCMD:=$(CROSS_PATH)/bin/$(CROSS_PREFIX)strip --strip-unneeded
#
# cpio
#
CPIO_BASE:=$(IMAGE_DIR)/minirootfs.cpio
CPIO_TARGET:=$(CPIO_BASE).gz
#
# gzip
#
COMPRESSOR:=gzip -9 -c

TARGETS:= busybox

HOST_TARGETS:= makedevs


all: images

clean: image-clean makedevs-clean busybox-clean

dirclean: busybox-dirclean

#########################################################################
#
# Host tools
#
#########################################################################

makedevs: $(MAKEDEVS_DIR)/makedevs
	$(HOSTCC) -Wall -Werror -O2 $(MAKEDEVS_DIR)/makedevs.c 		\
		-o $(MAKEDEVS_DIR)/makedevs

makedevs: $(MAKEDEVS_DIR)/makedevs

makedevs-clean:
	rm -f $(MAKEDEVS_DIR)/makedevs

#########################################################################
#
# Busybox
#
#########################################################################

BUSYBOX_VERSION:=1.9.2

$(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2:
	wget -O $(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2	\
		http://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2

$(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION): $(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2
	tar xf $(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2 -C $(BUSYBOX_DIR)

$(ROOTFS_DIR)/bin/busybox: $(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION)
	cp $(BUSYBOX_DIR)/busybox.config 				\
		$(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION)/.config
	yes "" | make -C $(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION) oldconfig
	make V=1 CC="$(CROSS_CC)" CROSS_COMPILE="$(CROSS_PREFIX)" 	\
		CONFIG_PREFIX="$(IMAGE_DIR)/rootfs" 			\
		EXTRA_CFLAGS="$(CROSS_CFLAGS)" 				\
		EXTRA_LDFLAGS="$(CROSS_LDFLAGS)"			\
		-C $(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION) install

busybox: $(ROOTFS_DIR)/bin/busybox

busybox-clean: busybox-dirclean
	make -C $(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION) 		\
		CONFIG_PREFIX=$(IMAGE_DIR)/rootfs uninstall
	make -C $(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION) clean

busybox-dirclean:
	rm -rf $(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION)
	rm -f $(BUSYBOX_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2

#########################################################################
#
# Initial ramfs
#
#########################################################################

$(CPIO_BASE): rootfs_skel $(TARGETS)
	#
	# First copy the target_skeleton into the final root filesystem
	#
	cp -a $(ROOTFS_SKEL_DIR)/* $(ROOTFS_DIR)
	#
	# Strip rootfs binaries
	#
	#find $(ROOTFS_DIR) -type f -perm +111 | xargs $(STRIPCMD)
	#
	# Use fakeroot to pretend to create all needed device nodes
	#
	echo "chown -R 0:0 $(ROOTFS_DIR)" 	> $(IMAGE_DIR)/_fakeroot
	echo "$(MAKEDEVS_DIR)/makedevs -d $(IMAGE_DIR)/device_table.txt $(ROOTFS_DIR)" 	\
						>> $(IMAGE_DIR)/_fakeroot
	# Use fakeroot so tar believes the previous fakery
	echo "cd $(ROOTFS_DIR) && find . | cpio --quiet -o -H newc > $(CPIO_BASE)" 	\
						>> $(IMAGE_DIR)/_fakeroot
	chmod a+x $(IMAGE_DIR)/_fakeroot
	fakeroot -- $(IMAGE_DIR)/_fakeroot
	rm -f $(IMAGE_DIR)/_fakeroot

$(CPIO_TARGET): $(CPIO_BASE)
	$(COMPRESSOR) $(CPIO_BASE) > $(CPIO_TARGET)

initramfs: $(HOST_TARGETS) $(CPIO_TARGET)

initramfs-clean: 
	rm -f $(IMAGE_DIR)/minirootfs.cpio.gz
	rm -f $(IMAGE_DIR)/minirootfs.cpio

#########################################################################
#
# Initial ramdisk
#
#########################################################################

$(IMAGE_DIR)/minirootfs.gz: rootfs_skel $(TARGETS)
	# Then generate the ext2 filesystem
	genext2fs -d $(ROOTFS_DIR) --number-of-inodes 256 		\
		--reserved-percentage 0 --size-in-blocks 2048 		\
		--devtable $(IMAGE_DIR)/device_table.txt 		\
		$(IMAGE_DIR)/minirootfs.ext2
	$(COMPRESSOR) $(IMAGE_DIR)/minirootfs.ext2 > $(IMAGE_DIR)/minirootfs.gz

initrd: $(IMAGE_DIR)/minirootfs.gz

initrd-clean: 
	rm -f $(IMAGE_DIR)/minirootfs.gz
	rm -f $(IMAGE_DIR)/minirootfs.ext2

#########################################################################
#
# Rootfs skeleton
#
#########################################################################

$(ROOTFS_DIR):
	# Copy the target_skeleton into the final root filesystem
	cp -a $(ROOTFS_SKEL_DIR) $(ROOTFS_DIR)

rootfs_skel: $(ROOTFS_DIR)

rootfs_skel-clean:
	rm -rf $(ROOTFS_DIR)

#########################################################################
#
# Image
#
#########################################################################

images: initramfs initrd

image-clean: initramfs-clean initrd-clean
	rm -rf $(ROOTFS_DIR)

.PHONY: image rootfs_skel initrd initramfs busybox makedevs

