# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ ... }:

let
  common = import ./common.nix;
  pkgs = common.pkgs;
in common.utils.mergeSets common.config {

  boot.kernelModules = [
    "nct6775" # access to all sensors
  ];

  networking.hostName = "thia";

  # headless (TODO)
  services.xserver = {
    overrideThisSet = true;
    enable = true;
    videoDrivers = [ "nvidia" ]; # see 'nvidia' NixOS wiki article
  };

  users.users.laerling = let l = common.config.users.users.laerling; in {
    extraGroups = l.extraGroups ++ [
      "docker"  # Can be used for privilege escalation if Docker daemon runs as root!
      "scanner" # access to scanners
      "lp"      # access to scanners that are also printers
    ];
    packages = l.packages ++ (with pkgs; [
      mesa-demos nvtopPackages.nvidia ollama-cuda
    ]);
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;

    host = "0.0.0.0";
    port = 42069;
    openFirewall = true;

    # create user and group in order to be able to chown the models directory
    user = "ollama";
    group = "ollama";
    #FIXME Error: mkdir /home/nobackup: permission denied: ensure path elements are traversable
    #models = "/home/nobackup/.ollama/models";
    environmentVariables.OLLAMA_CONTEXT_LENGTH = "128000";
  };

  services.openssh = {
    enable = true;
    ports = [ 69 ];
    settings = {
      ChallengeResponseAuthentication = false;
      LoginGraceTime = 0; # prevent timeout that might be exploitable via CVE-2024-6387
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      PrintMotd = false;
      UsePAM = false;
      X11Forwarding = false;
      AllowUsers = [ "laerling" ];
    };
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
