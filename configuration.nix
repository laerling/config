# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

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

{
  imports = [ /etc/nixos/hardware-configuration.nix ];
  # TODO For more hardware-specific settings (and - according to the NixOS user manual - hardware configuration for known hardware), see https://github.com/NixOS/nixos-hardware

  # boot
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # low-level settings
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  services.logind.lidSwitch = "ignore";
  networking = {
    networkmanager.enable = true;

    # names
    hostName = "gem";
    hosts = let hostsPath = ./hosts.nix; in
            if builtins.pathExists hostsPath then import hostsPath else {};

    # DHCP
    useDHCP = false; # Deprecated. ALWAYS set to false!
    interfaces.enp0s31f6.useDHCP = true;
    interfaces.wlp61s0.useDHCP = true;

    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
  };

  # GUI
  services.xserver = {
    enable = true;
    layout = if choose "neo" then "de" else "us";
    xkbVariant = if choose "neo" then "neo" else "altgr-intl";
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
  # explicitely enable gnome-terminal, because the new one is still shit
  programs.gnome-terminal.enable = true;

  # TODO: Changes in generation update that might be connected to the
  # root cause of the terminal vs. screen bug:

  # freetype-2.11.0 => freetype-2.12.0
  # => freeglut-3.2.1
  # fribidi-1.0.10 => fribidi-1.0.12
  # gpm-1.20.7 => gpm-unstable-2020-06-17
  # harfbuzz-3.0.0 => harfbuzz-3.3.2
  # harfbuzz-icu-3.0.0 => harfbuzz-icu-3.3.2

  # sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # system packages - only bare necessities
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [ screen vim wget ];

  # Users - Don't forget to set a password with ‘passwd’!
  users.groups."laerling".gid = 1001;
  users.users.laerling = {
    description = "Benjamin Ludwig";
    isNormalUser = true;
    uid = 1000;
    group = "laerling";
    createHome = true;
    home = "/home/laerling";
    extraGroups = [ "wheel" "adbusers" ];

    # TODO: system packages go to /, user packages go to /etc/profiles/per-user/<user>, packages installed via nix-env go to /home/<user>/.nix-profile/
    packages = let
      ownPkgs = import ./pkgs { inherit pkgs; };
      allPkgs = pkgs // ownPkgs;
    in
      with allPkgs; let
        base       = [ borgbackup file git gnumake jq killall nixos-option nixos-utils lm_sensors screen tree unzip vim wget xxHash ];
        # breeze-icons contains icons for kolourpaint
        gui_base   = [ breeze-icons firefox gnome-passwordsafe gnome.gnome-tweaks kolourpaint pavucontrol source-code-pro ];
        gui_ubuntu = [ gnomeExtensions.dash-to-dock ubuntu_font_family ubuntu-themes yaru-theme ];
        dev        = [ emacs ];
        dev_rust   = [ cargo gcc rustc ]; # see https://nixos.wiki/wiki/Rust
        leisure    = [ discord mpv tdesktop thunderbird-bin youtube-dl ];
      in base ++ gui_base ++ gui_ubuntu ++ dev ++ dev_rust ++ leisure;
  };

  # other programs and services
  programs.adb.enable = choose "adb";
  programs.steam.enable = choose "steam";
  programs.wireshark.enable = choose "wireshark";
  services.postgresql = choose "postgres";
  virtualisation.virtualbox.host.enable = choose "virtualbox";

  # environment and shell
  environment = {
    etc."mpv/mpv.conf".text = "audio-display=no";
    variables = {
      NIXPKGS_ALLOW_UNFREE = "1";
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

      alias s='screen -DRU -e ^xx'
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}

