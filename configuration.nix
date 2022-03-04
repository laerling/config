# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  # boot
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # low-level settings
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  networking = {

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
    layout = "de";
    xkbVariant = "neo";
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

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

    packages = let
      ownPkgs = import ./pkgs { inherit pkgs; };
      allPkgs = pkgs // ownPkgs;
    in
      with allPkgs; let
        base       = [ borgbackup file git gnumake killall nixos-utils lm_sensors screen tree unzip vim wget ];
        # breeze-icons contains icons for kolourpaint
        gui_base   = [ breeze-icons firefox gnome-passwordsafe gnome.gnome-tweaks kolourpaint pavucontrol source-code-pro ];
        gui_ubuntu = [ gnomeExtensions.dash-to-dock ubuntu_font_family ubuntu-themes yaru-theme ];
        dev        = [ emacs ];
        leisure    = [ discord mpv tdesktop thunderbird-bin youtube-dl ];
      in base ++ gui_base ++ gui_ubuntu ++ dev ++ leisure;
  };

  # other programs and services
  programs.adb.enable = true;
  programs.steam.enable = true;

  # environment and shell
  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    EDITOR = "vim";
    VISUAL = "vim";
  };
  programs.bash.interactiveShellInit = ''
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}

