# Change Boot Device

Once you have succesfully migrated to a new storage Device you need to change the boot order to this device and specify it in FStab or boot from an intermediary device. Personally I've never been able to boot from USB without modifying the SBC's internals.

## ARMbian

3.  **Configure U-Boot to Boot from USB**: (armbian specific)
   - Point variable in the u-boot env configuration file to new Storage Device, reboot to apply:
     ```bash
     sudo sed -i 's/^rootdev=.*/rootdev=UUID=your-new-uuid/' /mnt/ssd_root/boot/armbianEnv.txt
     sudo reboot now
     ```

