# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).


{ config, lib, pkgs, ... }:

let

  choose = keyname: chooseOrDefault keyname false;
  # TODO rename to chooseOrCustomDefault (including all occurences)
  # and define chooseOrDefault with default being the NixOS option
  # default value.
  chooseOrDefault = keyname: default: let
    path=./choices.nix;
    choices = import path;
  in if builtins.pathExists path && choices ? "${keyname}"
  then choices."${keyname}" else default;

  chosenPackages = if choose "minecraft"
    then with pkgs; [ prismlauncher ] else [];

in {

  imports =
    [ # Include the results of the hardware scan.
      # For more hardware-specific settings (and - according to the
      # NixOS user manual - hardware configuration for known
      # hardware), see https://github.com/NixOS/nixos-hardware
      /etc/nixos/hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # boot
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # low-level settings
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  services.logind.lidSwitch = "ignore"; # Also an option: "lock"
  networking = {
    hostName = "saito";
    hosts = if builtins.pathExists ./hosts.nix then import ./hosts.nix else {};

    # On desktop managers like Gnome it is enough to enable NetworkManager and
    # add the user to the "networkmanager" group.
    networkmanager.enable = true;
    #networkmanager.backend = "iwd";
    #wireless.iwd.enable = true; # IWD

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # firewall.enable = false;
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # GUI
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ]; # see 'nvidia' NixOS wiki article
    xkb.layout = if choose "neo" then "de" else "us";
    xkb.variant = if choose "neo" then "neo" else "altgr-intl";
    xkb.options = "eurosign:e"; # Also an option: "caps:escape"

  } // (let
    kde = false;
  in
    if kde then {
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    } else {
      # FIXME: With lightdm the screen can't be locked (e.g. after waking up from suspend)
      #displayManager.lightdm = {
      #  enable = true;
      #  greeters.slick = {
      #    enable = true;
      #    theme.package = pkgs.yaru-theme;
      #    theme.name = "Yaru";
      #    iconTheme.package = pkgs.humanity-icon-theme;
      #    iconTheme.name = "Humanity-Dark";
      #    cursorTheme.name = "Yaru";
      #  };
      #};

      # TODO: unity(d) and/or unityx - https://unityd.org/
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    });
  # Don't use Lomiri (formerly Unity8) - it is clearly made for Ubuntu Touch and not for desktops! It's really bad...
  #services.desktopManager.lomiri.enable = true;

  # Sound
  sound.enable = true; # ALSA
  hardware.pulseaudio.enable = true;
  # pipewire (somehow doesn't work)
  #hardware.pulseaudio.enable = false; # required by pipewire
  #security.rtkit.enable = true; # realtime capabilities
  #services.pipewire = {
  #  enable = true;
  #  audio.enable = true; # use as primary audio server
  #  # enable emulations when needed
  #  alsa.enable = true;
  #  pulse.enable = true;
  #  #jack.enable = true;
  #};

  # same GID and UID as on Ubuntu
  users.groups.laerling.gid = 1000;
  users.users.laerling = {
    isNormalUser = true;
    uid = 1000;
    group = "laerling";
    # sudo only works with group "wheel"
    extraGroups = [ "adbusers" "networkmanager" "wheel" "vboxusers" ];
    packages = with pkgs; let
      gnome-packages = with gnome; [ gnome-tweaks dconf-editor];
      ubuntu-style = [ humanity-icon-theme ubuntu_font_family ubuntu-themes
        yaru-theme ] ++ (with gnomeExtensions; [ dash-to-dock user-themes ]);
    in [
      # breeze-icons contains icons for kolourpaint
      # TODO check that nc points to the one in netcat-gnu
      bc borgbackup breeze-icons cargo curl discord drawpile emacs29 ffmpeg
      file firefox git gnumake jq keepassxc killall kolourpaint krita
      lm_sensors man-pages mpv netcat-gnu pavucontrol telegram-desktop
      thunderbird tree unzip wget xxHash youtube-dl
    ] ++ gnome-packages ++ ubuntu-style ++ chosenPackages;
  };

  # system-wide packages
  # - only bare necessities that are regularly needed for administration stuff
  #   (everything else can be pulled in via nix-shell
  # - only programs that are allowed to run as root
  environment.systemPackages = with pkgs; [
    bintools efibootmgr gptfdisk screen vim-full ];
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
    ] ++ (with pkgs.gnome; [
      epiphany geary gnome-calendar gnome-tour totem xterm yelp
    ]);

  # other programs and services
  programs = {
    adb.enable = choose "adb";
    steam.enable = choose "steam";
    wireshark.enable = choose "wireshark";
  };
  services.postgresql = choose "postgres";
  virtualisation = {
    anbox.enable = choose "anbox";
    docker.enable = choose "docker";
    virtualbox.host.enable = choose "virtualbox";
  };

  # environment and shell
  environment = {
    etc."mpv/mpv.conf".text = "audio-display=no";
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

