# Arch Linux [installation](https://wiki.archlinux.org/index.php/Installation_guide) checklist

## live system
It is recommended to use GNU screen!
1) verify boot mode: `efivar --list` or `ls /sys/firmware/efi/efivars/`
2) connect to internet (use `iwctl` for WLAN)
3) update system clock: `timedatectl set-ntp true`
4) partition disks (use `lsblk` to check which disk to use)
5) format partitions (FAT32 for EFI system partition (ESP): `mkfs.fat -F32`)
6) mount partitions (root: `/mnt`, efi/boot: `/mnt/boot`)
   Note that we're not using a separate boot partition in this case, but mount the ESP as `/boot`.
   I'm not sure, but I think this might be necessary for `systemd-boot` to find the kernel, initrds etc.
7) select mirrors (they're already ranked)
8) `pacstrap /mnt base linux linux-firmware sudo which dhcpcd git nano screen` and on the laptop `iwd`
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
22) configure systemd-boot (This assumes you do not have separate ESP and BOOT partitions):
```
cat > /boot/loader/loader.conf
default arch.conf
timeout 2
```
23) exit arch-chroot, `sync` and reboot into freshly installed system

## installed system
24) Connect to internet (use `iwctl` for WLAN) and get a DHCP lease: `systemctl start dhcpcd`
25) clone this repo: `git clone https://github.com/laerling/config ~/config && cd ~/config`
26) execute `./bootstrap.sh` and install a holodeck
27) reboot and logon as user
28) delete `/root/config` and adjust entry in `/etc/pacman.conf`, then `make update`

## cosmetical changes (Gnome desktop Ubuntu style)
For the following steps the AUR packages noted in [hologram-desktop-gnome](./hologram-desktop-gnome.toml) have to be installed.

### settings:
29) Set a desktop wallpaper, e.&nbsp;g. [this generic one](https://news-cdn.softpedia.com/images/news2/ubuntu-16-04-lts-wallpapers-revealed-for-desktop-and-phone-501169-2.jpg).

### tweaks:
30) General:
  - Untick "Suspend when Laptop lid is closed"
31) Extensions: Activate extensions. Deactivate everything except:
  - Dash to dock
  - Removable drive menu
  - User themes
  - Windownavigator
32) Appearance (extensions have to be configured first! See above):
  - Set all themes to yaru (AUR packages have to be installed, see above)
33) Fonts:
  - Interface Text: Ubuntu Regular 11
  - Document Text: Sans Regular 11
  - Monospace Text: Ubuntu Mono Regular 13
  - Legacy Window Titles: Ubuntu Bold 11
34) Adjust terminal preferences:
  - Untick "Use colors from system theme"
  - Set background color to `#300A24`
  - Set foreground color to `#FFFFFF`
  - Set palette to 'Tango'
35) Top Bar
  - Optionally activate "Battery Percentage"
  - Activate "Weekday"
  - Activate "Week Numbers"
36) Window Titlebars
  - Middle-Click: Minimize
  - Titlebar buttons: Maximize, Minimize
