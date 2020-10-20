# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
  # hardware scan
  imports = [ /etc/nixos/hardware-configuration.nix ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking = {
    hostName = "ana";
    useDHCP = false; # Deprecated. ALWAYS set to false!
    interfaces.enp0s25.useDHCP = true;
    interfaces.wlp2s0.useDHCP = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

  nixpkgs.config.allowUnfree = true; # needed for Discord, ...
  environment.systemPackages = with pkgs; let
    base     = [ file git gnumake screen vim wget ];
    base_gui = [ gnome3.gnome-tweaks ];
    dev      = [ emacs rustup ];
    leisure  = [ discord mpv qutebrowser tdesktop ];
  in base ++ base_gui ++ dev ++ leisure;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver = {
    enable = true;
    libinput.enable = true; # touchpad support
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
  };

  # Don't forget to set a password with ‘passwd’!
  users.users.laerling = {
    isNormalUser = true;
    createHome = true;
    home = "/home/laerling";
    extraGroups = [ "wheel" ];
  };
}
