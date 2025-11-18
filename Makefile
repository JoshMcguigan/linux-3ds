TARGET_DIR := output
LOADER := $(TARGET_DIR)/firm_linux_loader.firm
INITRAMFS := $(TARGET_DIR)/initramfs.cpio.gz
ARM9FW := $(TARGET_DIR)/arm9linuxfw.bin
KERNEL_IMAGE := $(TARGET_DIR)/zImage
KERNEL_DTB_CTR := $(TARGET_DIR)/nintendo3ds_ctr.dtb
KERNEL_DTB_KTR := $(TARGET_DIR)/nintendo3ds_ktr.dtb

# SD card image configuration
SDCARD_IMG := $(TARGET_DIR)/sdcard.img
SDCARD_SIZE_MB := 512

LOADER_ARTIFACT_FIRM := firm_linux_loader/firm_linux_loader.firm

BR_ARTIFACT_ENV_SETUP := buildroot/output/host/environment-setup
BR_ARTIFACT_ROOTFS := buildroot/output/images/rootfs.cpio.gz

ARM9FW_ARTIFACT_BIN := arm9linuxfw/arm9linuxfw.bin

KERNEL_ARTIFACT_IMAGE := output/linux-build/arch/arm/boot/zImage
KERNEL_ARTIFACT_DTB_CTR := output/linux-build/arch/arm/boot/dts/nintendo3ds_ctr.dtb
KERNEL_ARTIFACT_DTB_KTR := output/linux-build/arch/arm/boot/dts/nintendo3ds_ktr.dtb

.PHONY: all clean sdcard

all: $(LOADER) $(INITRAMFS) $(ARM9FW) $(KERNEL_IMAGE) $(KERNEL_DTB_CTR) $(KERNEL_DTB_KTR) $(SDCARD_IMG)

$(TARGET_DIR):
	mkdir -p $@

$(LOADER): | $(TARGET_DIR)
$(LOADER): $(LOADER_ARTIFACT_FIRM)
	cp $(LOADER_ARTIFACT_FIRM) $(TARGET_DIR)

$(LOADER_ARTIFACT_FIRM): SHELL=/bin/bash
$(LOADER_ARTIFACT_FIRM):
	CC=arm-none-eabi-gcc $(MAKE) -C firm_linux_loader

$(INITRAMFS): | $(TARGET_DIR)
$(INITRAMFS): $(BR_ARTIFACT_ROOTFS)
	cp $(BR_ARTIFACT_ROOTFS) $(INITRAMFS)

$(BR_ARTIFACT_ENV_SETUP) $(BR_ARTIFACT_ROOTFS):
	$(MAKE) -C buildroot nintendo3ds_defconfig
	$(MAKE) -C buildroot all

$(ARM9FW): | $(TARGET_DIR)
$(ARM9FW): $(ARM9FW_ARTIFACT_BIN)
	cp $(ARM9FW_ARTIFACT_BIN) $(ARM9FW)

$(ARM9FW_ARTIFACT_BIN): SHELL=/bin/bash
$(ARM9FW_ARTIFACT_BIN):
	TRIPLET=arm-none-eabi $(MAKE) -C arm9linuxfw

$(KERNEL_IMAGE): | $(TARGET_DIR)
$(KERNEL_IMAGE): $(KERNEL_ARTIFACT_IMAGE)
	cp $(KERNEL_ARTIFACT_IMAGE) $(KERNEL_IMAGE)

$(KERNEL_DTB_CTR): | $(TARGET_DIR)
$(KERNEL_DTB_CTR): $(KERNEL_ARTIFACT_DTB_CTR)
	cp $(KERNEL_ARTIFACT_DTB_CTR) $(KERNEL_DTB_CTR)

$(KERNEL_DTB_KTR): | $(TARGET_DIR)
$(KERNEL_DTB_KTR): $(KERNEL_ARTIFACT_DTB_KTR)
	cp $(KERNEL_ARTIFACT_DTB_KTR) $(KERNEL_DTB_KTR)

$(KERNEL_ARTIFACT_IMAGE): SHELL=/bin/bash
$(KERNEL_ARTIFACT_IMAGE) $(KERNEL_ARTIFACT_DTB_CTR) $(KERNEL_ARTIFACT_DTB_KTR): $(BR_ARTIFACT_ENV_SETUP)
	. $(BR_ARTIFACT_ENV_SETUP); \
	ARCH=arm CROSS_COMPILE=arm-linux- $(MAKE) -C linux O=../output/linux-build nintendo3ds_defconfig all

$(SDCARD_IMG): $(LOADER) $(INITRAMFS) $(ARM9FW) $(KERNEL_IMAGE) $(KERNEL_DTB_CTR) $(KERNEL_DTB_KTR)
	dd if=/dev/zero of=$(SDCARD_IMG) bs=1M count=$(SDCARD_SIZE_MB) status=progress
	mformat -F -i $(SDCARD_IMG) ::
	mmd -i $(SDCARD_IMG) ::/luma
	mmd -i $(SDCARD_IMG) ::/luma/payloads
	mmd -i $(SDCARD_IMG) ::/linux
	mcopy -i $(SDCARD_IMG) $(LOADER) ::/luma/payloads/
	mcopy -i $(SDCARD_IMG) $(KERNEL_IMAGE) ::/linux/
	mcopy -i $(SDCARD_IMG) $(INITRAMFS) ::/linux/
	mcopy -i $(SDCARD_IMG) $(ARM9FW) ::/linux/
	mcopy -i $(SDCARD_IMG) $(KERNEL_DTB_CTR) ::/linux/
	mcopy -i $(SDCARD_IMG) $(KERNEL_DTB_KTR) ::/linux/

sdcard: $(SDCARD_IMG)

clean:
	$(MAKE) -C firm_linux_loader clean
	$(MAKE) -C buildroot clean
	$(MAKE) -C arm9linuxfw clean
	$(MAKE) -C linux clean
	rm -rf $(TARGET_DIR)
