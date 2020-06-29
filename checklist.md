# Arch Linux [installation](https://wiki.archlinux.org/index.php/Installation_guide) checklist

## live system
It is recommended to use GNU screen!
1) verify boot mode: `efivar --list` or `ls /sys/firmware/efi/efivars/`
2) connect to internet
3) update system clock: `timedatectl set-ntp true`
4) partition disks (use `lsblk` to check which disk to use)
5) format partitions (FAT32 for EFI system partition (ESP): `mkfs.fat -F32`)
6) mount partitions (root: `/mnt`, efi/boot: `/mnt/boot`)
7) select mirrors (they're already ranked)
8) `pacstrap /mnt base linux linux-firmware dhcpcd git`
9) `genfstab -U /mnt >> /mnt/etc/fstab`
10) `arch-chroot /mnt` (all following steps have to be done in the arch-chroot environment!)

## arch-chroot
11) set timezone: `ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime`
12) create `/etc/adjtime`: `hwclock --systohc`
13) create locales: Edit `/etc/locale.gen`: Uncomment `en_US.UTF-8 UTF-8`. Then run `locale-gen`
14) create `/etc/hostname`
15) append to `/etc/hosts`:
```
127.0.0.1       localhost
::1             localhost
```
16) set root password: `passwd`
17) add [encryption](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LUKS_on_a_partition) hook to initial ramdisk: `sed -i '/^HOOKS/s/(.*)/(base udev autodetect keyboard modconf block encrypt filesystems fsck)/' /etc/mkinitcpio.conf`
18) Rebuild initial ramdisk: `mkinitcpio -p linux`
19) install [microcode](https://wiki.archlinux.org/index.php/Microcode#systemd-boot): `pacman -S amd-ucode` (or `pacman -S intel-ucode`)
20) install systemd-boot: `bootctl install`
21) create Arch Linux boot entry with enabled microcode loading and root disk decryption parameter:
NOTE: `<ROOT_PARTITION_UUID>` is the UUID of the unencrypted root partition, NOT of the device mapper file (`dm-0`)!
```
cat > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options cryptdevice=UUID=<ROOT_PARTITION_UUID>:root root=/dev/mapper/root rw
```
22) configure systemd-boot:
```
cat > /boot/loader/loader.conf
default arch.conf
timeout 2
```
23) exit arch-chroot, `sync` and reboot into freshly installed system

## installed system
24) get a DHCP lease: `systemctl start dhcpcd`
25) clone this repo: `git clone https://github.com/laerling/config ~/config && cd ~/config`
26) execute `./bootstrap`
27) reboot and logon as user
28) delete `/root/config` and adjust entry in `/etc/pacman.conf`, then `make update`
