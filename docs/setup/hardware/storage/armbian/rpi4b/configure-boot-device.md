# Configure SSD as bootable device

Raspberry pi and ubuntu based distro's have very nice integrated USB booting. You'll only need 2 steps

## **Understanding Boot Partition Requirements**

### **Raspberry Pi Boot Process**

- **FAT32 Partition Necessity**:
  - **Firmware Design**: The Raspberry Pi's firmware is designed to look for boot files on a FAT32 partition. This is a requirement set by the Broadcom SoC used in Raspberry Pi devices.
  - **Bootloader Constraints**: The primary bootloader resides in the GPU's ROM and expects to find the secondary bootloader and kernel images on a FAT32-formatted partition. This is why all standard Raspberry Pi OS images include a small FAT32 partition (commonly labeled `/boot`) and a larger ext4 partition for the root filesystem.

- **USB Booting**:
  - **EEPROM Configuration**: For Raspberry Pi 4 and later models, the ability to boot from USB devices (like SSDs) is facilitated by updating the bootloader EEPROM to support USB boot. Once configured, the bootloader still searches for the necessary boot files on a FAT32 partition on the USB device.


## Guide

1. **Change the Boot Order**
   - If you haven't already configured your Pi to boot from USB, you can do this using the Raspberry Pi Imager:
     1. Open Raspberry Pi Imager on your computer.
     2. Select ``"Misc utility images" > "bootloader utility (Raspberry pi 4 family)"``.
     3. Choose ``USB Boot`` to set the bootloader to prefer USB.
     4. Write the image to an SD card.
     5. Insert the SD card into your Raspberry Pi and boot it. This will update the EEPROM to boot from USB first.
     6. After a successful update (indicated by a green screen), power off the Pi and remove the SD card.

2. **Write Ubuntu Image to the SSD**
   - Download the official Ubuntu image for Raspberry Pi from the [Ubuntu website](https://ubuntu.com/download/raspberry-pi) or in our case use the [custom](https://fi.mirror.armbian.de/dl/rpi4b/archive/) armbian one that is based off noble.
   - Use Raspberry Pi Imager or another imaging tool to write the Ubuntu image directly to the SSD.

3. **Boot from the SSD**
   - Connect the SSD to your Raspberry Pi 4.
   - **Ensure no SD card is in the Raspberry Pi.**
   - Power on the Raspberry Pi. It should boot directly from the SSD.



You are correct in noticing that the Armbian image for the Rock 5B does not contain a FAT32 partition, unlike some Raspberry Pi images. This difference stems from the distinct boot processes and firmware requirements of these two boards. Let's delve deeper into understanding why this is the case and how it affects the booting mechanisms for both devices.

---