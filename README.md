# config

This repo shall bundle as much config as possible.
Currently it only works with Arch Linux systems.
It assumes the disk has been partitioned and the `base` package group has been pacstrapped.
Also, the hostname has to be set manually (write it to /etc/hostname).


## Building
On a blank system with just the 'base' group and the root user, just run `./bootstrap.sh`.
After changing something, run `sudo make`. The changes are then being installed.
This upgrades the whole system. If you want to only update the package databases, run `sudo make update`.

The following important targets are defined in the Makefile:
- `all`: Install holo and holo-build, make the config repository, and register it
- `repo`: Build holodecks and holograms and put them into the repository
- `holodecks`, `holograms`: Build holodecks and holograms, respectively

The following dependency targets might be useful as well:
- `holo-repo_registration`: Register the `holo` repo in `/etc/pacman.conf` (contains holo and holo-build)
- `config-repo_registration`: Register the `config` repo in `/etc/pacman.conf` (contains the holodecks and holograms)
- `/usr/bin/holo-build`, `/usr/bin/holo`: Download signing keys and install `holo` and `holo-build`


## holo conventions

![hologram dependency tree rendering](./tree.png)

- hologram packages shall be named `hologram-name` where `name` is an arbitrary descriptive name, e. g. `hologram-games`
- In the tree (see above) holograms are displayed not by their actual package name but by the name of their ambiguators (The directory names used below `/usr/share/holo/*/`).
- The number of a disambiguator shall be two digits long and as low as possible without being lower than the number of any dependency. The following exceptions exist:
  - The number of the disambiguator of `hologram-base` shall be `00` always. No other hologram must have this number. This means that other holograms have at least `01`. Every holodeck must depend on `hologram-base`.
  - The number of the disambiguator of a holodeck shall be `99` always. No hologram must have this number.

## Arch Linux [installation](https://wiki.archlinux.org/index.php/Installation_guide) checklist

### live system
It is recommended to use screen
1) verify boot mode: `ls /sys/firmware/efi/efivars/`
2) connect to internet
3) update system clock: `timedatectl set-ntp true`
4) partition disks (use lsblk to check which disk to use)
5) format partitions (FAT32 for EFI (`mkfs.fat -F32`))
6) mount partitions (root: `/mnt`, efi: `/mnt/efi`, boot: `/mnt/boot`)
7) select and rank mirrors (`rankmirrors` in package `pacman-contrib`)
8) `pacstrap /mnt base linux linux-firmware`
9) `genfstab -U /mnt >> /mnt/etc/fstab`
10) `arch-chroot /mnt` (all following steps have to be done in the arch-chroot environment!)
11) `ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime`
12) create `/etc/adjtime`: `hwclock --systohc`
13) create `/etc/hostname`
14) append to `/etc/hosts`:
```
127.0.0.1       localhost
::1             localhost
```
15) set root password: `passwd`
16) enable [microcode](https://wiki.archlinux.org/index.php/Microcode#GRUB) updates (`grub-mkconfig` will detect the package): `pacman -S intel-ucode` or `pacman -S amd-ucode`
17) mount EFI system partition (ESP) to `/efi` and boot partition to `/boot`
18) add [encryption](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LUKS_on_a_partition) hook to initial ramdisk: `sed -i '/^HOOKS/s/block /&encrypt /;' /etc/mkinitcpio.conf` (must contain udev and keyboard hooks as well)
19) Rebuild initial ramdisk: `mkinitcpio -p linux`
20) install `grub` and `efibootmgr` packages
21) install GRUB EFI application: `grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB`
22) add kernel command line parameter for root partition decryption: `sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ cryptdevice=UUID=<ROOT_PARTITION_UUID>:root root=\/dev\/mapper\/root"/' /etc/default/grub` (replace `<ROOT_PARTITION_UUID>` with UUID of root partition)
23) generate the [main configuration file](https://wiki.archlinux.org/index.php/GRUB#Generate_the_main_configuration_file) in `/boot/grub/grub.cfg` (do this after every change to `/etc/default/grub` or `/etc/grub.d/`): `grub-mkconfig -o /boot/grub/grub.cfg`

### installed system
24) exit arch-chroot and reboot into installed system, logon as root
TODO: HOLO STUFF

### The boot process goes something like this
1) POST executes
2) EFI executes and reads entries from NVRAM, one entry points to GRUB EFI executable in EFI system partition (ESP)
3) GRUB EFI executable applies the initial ramdisk and executes the kernel
4) root disk is decrypted and mounted at `/`, ESP at `/efi`, boot partition at `/boot`.


## FIXMEs and TODOs

### Build:
  - Make make return non-zero when a holo-build failed
  - Write holo plugin for cloning git repos (holo-git-repo)

### General:
  - ebox
  - vimrc (git clone ... && cd .vim && make && ...)
  - Backup mechanism (backuplocal script or borg)
  - Move aliases from bash.bashrc into profile (?)
  - Move aliases from bash.bashrc to fitting holograms (use #!/usr/bin/tee -a respectively)
  - Prompt user for password for laerling (passwd somehow doesn't work in the [[action]] hook)
  - Rerun GRUB config after holodeck install in order to include the intel-ucode initrd
  - C3D2 chat (z. B. profanity, (or if handling is simpler than profanity, bitlbee oder irssi+irssi-xmpp))
  - shell prompt by pattern <git-repo-name>/path/to/subdir/
  - Put recommendations for AUR packages into holograms?
    - E. g. hologram-audio: $(yaourt -Qi mp3splt) for splitting audio files (e. g. flies which are an entire album)
  - hologram-base: Activate numlock (not only the LEDs but really...)
  - firefox config via autoconfig (also see https://wiki.archlinux.org/index.php/Firefox ) (/usr/lib/firefox/defaults/pref/ etc....)
    - Make default browser
    - Plugin
      - umatrix
      - Decentraleyes
      - Tree Style Tab
  - vlc config (Allow only one instance, Enqueue items into playlist in one instance mode, use dark theme)
  - hologram-games
    - steam (multilib, but activate here, not in hologram-base. Pay attention, for it might already be activated)
    - minecraft unfortunately is a AUR package
  - Replace dolphin with another mtp-capable graphical file manager like nautilus, nemo, thunar, this awesome file manager I once tried, ...
  - hologram-latex: What was scribus for again?
  - Replace Shift+4 with $ on X for norwegian keyboard layout
  - Remove slockhib completely? I only use slocksus and hibernation does not work with encrypted swap anyway. Given, that I even use swap.

### Networking:
  - DHCP (but no long waiting when IF down) >See majewsky/system-configuration/holodeck-krikkit (also the # network setup: systemd-resolved is important!)
  - wpa_supplicant (see holodeck-krikkit)
  - DHCP: Use systemd matching on interface to abstract from LAN NIC

### GUI:
  - gnome terminal: Set config (colorscheme tango-dark, ...)
  - Use a terminal that doesn't rely on a server part and thus is usable on several ttys. That is, don't use gnome-terminal.
  - Terminal: Don't beep. Add /etc/modprobe.d/nobeep.conf with content "blacklist pcspkr" to hologram-base

### Other:
  - ebox: Force replacing .emacs.d by symlink when it's not a symlink
  - ebox: When switching, ask if .emacs.d shall be replaced by symlink if it's not a symlink
  - Set the EDITOR and VISUAL env vars to emacsclient in the spacemacs hologram (also in hologram-dev?)
