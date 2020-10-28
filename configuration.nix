# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

with builtins; {
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
  # hardware scan
  imports = [ /etc/nixos/hardware-configuration.nix ];

  # boot
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  # low-level settings
  hardware.pulseaudio.enable = true;
  i18n.defaultLocale = "en_US.UTF-8";
  sound.enable = true;
  time.timeZone = "Europe/Berlin";
  networking = {
    hostName = "ana";
    hosts = let hostsPath = ./hosts.nix; in
      if pathExists hostsPath then import hostsPath else {};
    useDHCP = false; # Deprecated. ALWAYS set to false!
    interfaces.enp0s25.useDHCP = true;
    interfaces.wlp2s0.useDHCP = true;
  };

  # GUI
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
  };

  # Users - Don't forget to set a password with ‘passwd’!
  users.users.laerling = {
    isNormalUser = true;
    createHome = true;
    home = "/home/laerling";
    extraGroups = [ "wheel" ];
  };

  # shell
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

    alias loop='mpv --loop-playlist'
    alias play='loop --shuffle'
    alias music='play --no-video ~/Musik/'
  '';

  # packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; let
    base       = [ file git gnumake screen tree unzip vim wget ];
    gui_base   = [ gnome3.gnome-tweaks kolourpaint source-code-pro ];
    gui_ubuntu = [ gnomeExtensions.dash-to-dock ubuntu_font_family ubuntu-themes yaru-theme ];
    dev        = [ emacs rustup ];
    leisure    = [ discord ffmpeg mpv qutebrowser tdesktop thunderbird-bin youtube-dl ];
  in base ++ gui_base ++ gui_ubuntu ++ dev ++ leisure;

}
