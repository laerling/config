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

  # packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; let
    base     = [ file git gnumake screen tree unzip vim wget ];
    base_gui = [ gnome3.gnome-tweaks kolourpaint ];
    dev      = [ emacs rustup ];
    leisure  = [ discord ffmpeg mpv qutebrowser tdesktop thunderbird-bin youtube-dl ];
  in base ++ base_gui ++ dev ++ leisure;

}
