# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let common = import ./common.nix { inherit pkgs; };
in common.utils.mergeSets common.config {

  networking.hostName = "togusa"; # Ghost in the Shell


  ########
  # TODO #
  ########
  # - Try X11Forwarding (for displaying separate windows instead of desktop)
  # - mesa-demos => tri => console output
  # - Xvfb
  # - x11vnc
  # - mesa-demos => tri => console output
  # - audio


  #############
  # low-level #
  #############

  # grub instead of systemd-boot. No EFI anyway.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;


  ##############
  # networking #
  ##############

  networking.interfaces.enp0s3.ipv4.addresses = [{
    address = "192.168.178.68"; # the final headless PC will have 69 of course
    prefixLength = 24;
  }];

  # TODO configure firewall when everything else is configured
  networking.firewall.enable = false;

  services.openssh = {
    enable = true;
    ports = [ 69 ];
    settings = {
      AllowUsers = [ "laerling" ];
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      UsePAM = false;
      X11Forwarding = true;
    };
  };


  ############
  # graphics #
  ############

  # since there is no X server installed, we have to manually enable OpenGL
  hardware.graphics.enable = true;
  #hardware.graphics.package = pkgs.mesa;
  services.xserver.enable = false;


  #########
  # sound #
  #########

  # TODO: Remote sound server. Avahi needed?
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire.enable = true;
  # services.pipewire.pulse.enable = true;


  ###############################
  # user, programs, environment #
  ###############################

  users.users.laerling = {
    extraGroups = [ "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ man-pages mesa-demos netcat-gnu ];
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
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

