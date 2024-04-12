# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

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
in

{ config, lib, pkgs, ... }:

{
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
    hostName = "suki";
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

  # GUI
  services.xserver = {
    enable = true;

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
      displayManager.gdm.enable = true;
      # ToDo:
      # wm/compositor: compiz (zukünftig unityx)
      # shell: unity 7 (zukünftig unityx)
      # theme: ambiance
      # icons: humanity
      desktopManager.gnome.enable = true;
    });

  # Sound
  sound.enable = true; # ALSA
  hardware.pulseaudio.enable = true;

  # same GID and UID as on Ubuntu
  users.groups.laerling.gid = 1000;
  users.users.laerling = {
    isNormalUser = true;
    uid = 1000;
    group = "laerling";
    # sudo only works with group "wheel"
    extraGroups = [ "adbusers" "networkmanager" "wheel" ];
    packages = with pkgs; let
      gnome-packages = with gnome; [ gnome-tweaks dconf-editor];
      ubuntu-style = [ humanity-icon-theme ubuntu_font_family ubuntu-themes
      yaru-theme ] ++ (with gnomeExtensions; [ dash-to-dock user-themes ]);
    in [
      # breeze-icons contains icons for kolourpaint
      bc borgbackup breeze-icons cargo curl discord drawpile emacs29 file
      firefox git gnumake jq keepassxc killall kolourpaint krita lm_sensors mpv
      telegram-desktop tree unzip wget xxHash youtube-dl
    ] ++ gnome-packages ++ ubuntu-style;
  };

  # system-wide packages
  # - only bare necessities that are regularly needed for administration stuff
  #   (everything else can be pulled in via nix-shell
  # - only programs that are allowed to run as root
  environment.systemPackages = with pkgs; [ efibootmgr gptfdisk screen vim-full ];
  environment.gnome.excludePackages = with pkgs.gnome; [ epiphany totem yelp ];

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
  programs.bash = {
    interactiveShellInit = ''
      # Add colors to less/man/...
      export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
      export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
      export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
      export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
      export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
      export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
      export LESS_TERMCAP_ue=$'\E[0m'        # reset underline
      export GROFF_NO_SGR=1                  # for konsole and gnome-terminal

      alias l='ls -Alh'
      alias la='ls -A'

      alias loop='mpv --loop-playlist'
      alias play='loop --shuffle'
      alias music='play --no-video ~/Music/'

      alias s='screen -h 1024 -DRU -e ^xx'
    '';
    promptInit = ''
      # Provide a nice prompt if the terminal supports it.
      if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
        PROMPT_COLOR="1;31m"
        ((UID)) && PROMPT_COLOR="1;32m"
        if [ -n "$INSIDE_EMACS" ] || [ "$TERM" = "eterm" ] || [ "$TERM" = "eterm-color" ]; then
          # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
          PS1="\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
        else
          PS1="\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
        fi
        if test "$TERM" = "xterm"; then
          PS1="\[\033]2;\h:\u:\w\007\]$PS1"
        fi
      fi
    '';
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

