# config

This repo shall bundle as much config as possible.
Currently it only works with Arch Linux systems.


## Bootstrapping a fresh Arch Linux system

For bootstrapping a fresh Arch Linux installation, read the [checklist](./checklist.md).
It covers the whole process of installation, including holo and holograms, so you can ignore the 'Building' section below.


## Building

After changing something, just run `make`. This builds the packages and updates pacmans package database.
This is the same as running `make update`. To build and upgrade the whole system, run `make upgrade`.

The following relevant `make` targets exist:
target | description
-|-
`all` | Install holo and holo-build, make the config repository, and register it
`repo` | Build holodecks and holograms and put them into the repository
`holodecks`, `holograms` | Build holodecks and holograms, respectively

The following dependency `make` targets might be useful as well:
target | description
-|-
`holo-repo_registration` | Register the `holo` repo in `/etc/pacman.conf` (contains holo and holo-build)
`config-repo_registration` | Register the `config` repo in `/etc/pacman.conf` (contains the holodecks and holograms)
`/usr/bin/holo-build`, `/usr/bin/holo` | Download signing keys and install `holo` and `holo-build`


## holo conventions

![hologram dependency tree rendering](./tree.png)

- hologram packages shall be named `hologram-name` where `name` is an arbitrary descriptive name, e.&nbsp;g. `hologram-games`
- In the tree (see above) holograms are displayed not by their actual package name but by the name of their ambiguators (The directory names used below `/usr/share/holo/*/`).
- The number of a disambiguator shall be two digits long and as low as possible without being lower than the number of any dependency. The following exceptions exist:
  - The number of the disambiguator of `hologram-base` shall be `00` always. No other hologram must have this number. This means that other holograms have at least `01`. Every holodeck must depend on `hologram-base`.
  - The number of the disambiguator of a holodeck shall be `99` always. No hologram must have this number.


## FIXMEs and TODOs

### Build:
  - Write holo plugin for cloning git repos (holo-git-repo)
  - Since `pacman.conf` is being holoscript'ed by [hologram-base-arch](./hologram-base-arch) (in [holoscripts/pacman.conf](./holoscripts/pacman.conf)), holo apply keeps nagging about it being altered by the user, after they run `make config-repo_registration`. I suppose holo generators can be used here to provision the repo into `/etc/pacman.conf` by using the absolute path of the current directory at hologram build time. All we'd need for an initial setup then is to run `pacman -U repo/holodeck-something.pkg.tar.gz`.
    - *However* when we move the config repo (e.&nbsp;g. after I clone it in `/root/` and then provision laerling and then move it to `/home/laerling/`), what happens then?
    - While we're at it, using generators, maybe we can somehow automatically generate shills for all jack clients in [hologram-studio-audio](./hologram-studio-audio)?

### General:
  - AUR plugin for AUR packages. To see which ones are needed, run `yaourt -Q|grep ^local' on e.&nbsp;g. Eve
  - Make it possible to provision home directory by parameterizing holodecks/holograms and run a preprocessor in the corresponding Makefile rules
  - git plugin: ebox
  - vimrc (git clone ... && cd .vim && make && ...)
  - Backup mechanism (backuplocal script or borg)
  - Move aliases from bash.bashrc into profile (?)
  - Move aliases from bash.bashrc to fitting holograms (use #!/usr/bin/tee -a respectively)
  - Prompt user for password for laerling (passwd somehow doesn't work in the [[action]] hook)
  - Rerun GRUB config after holodeck install in order to include the intel-ucode initrd
  - C3D2 chat (z. B. profanity, (or if handling is simpler than profanity, bitlbee oder irssi+irssi-xmpp))
  - shell prompt by pattern <git-repo-name>/path/to/subdir/
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
  - Run xorg-server without root rights with the help of systemd-logind
    > xorg-server has now the ability to run without root rights with
    > the help of systemd-logind. xserver will fail to run if not launched
    > from the same virtual terminal as was used to log in.
    > Without root rights, log files will be in ~/.local/share/xorg/ directory.
    > Old behavior can be restored through Xorg.wrap config file.
    > See Xorg.wrap man page (man xorg.wrap).
  - gnome terminal: Set config (colorscheme tango-dark, ...)
  - Use a terminal that doesn't rely on a server part and thus is usable on several ttys. That is, don't use gnome-terminal.
  - Terminal: Don't beep. Add /etc/modprobe.d/nobeep.conf with content "blacklist pcspkr" to hologram-base

### Other:
  - ebox: Force replacing .emacs.d by symlink when it's not a symlink
  - ebox: When switching, ask if .emacs.d shall be replaced by symlink if it's not a symlink
  - Set the EDITOR and VISUAL env vars to emacsclient in the spacemacs hologram (also in hologram-dev?)
