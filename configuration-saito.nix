# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let common = import ./common.nix { inherit pkgs; };
in common.utils.mergeSets common.config {

  networking.hostName = "saito";

  hardware = {
    # udev configuration for ZSA keyboards
    keyboard.zsa.enable = true;
    sane.enable = true;
  };

  # FIXME check version - see https://www.pcworld.com/article/2504035/security-flaws-found-in-all-nvidia-geforce-gpus-update-drivers-asap.html
  services.xserver.videoDrivers = [ "nvidia" ]; # see 'nvidia' NixOS wiki article

  users.users.laerling = let l = common.config.users.users.laerling; in {
    extraGroups = l.extraGroups ++ [
      "docker"  # Can be used for privilege escalation if Docker daemon runs as root!
      "scanner" # access to scanners
      "lp"      # access to scanners that are also printers
    ];
    packages = l.packages ++ (with pkgs; [ nvtopPackages.nvidia ]);
  };

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true; # let docker client know how to contact the daemon
  };

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
