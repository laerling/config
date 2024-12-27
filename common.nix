# we export a set containing configuration (config) and utiliy
# functions (utils). This is helpful because on one hand we use
# config to build the final configuration by merging it with a
# device-specific set in configuration-*.nix, on the other hand some
# of the configuration options within that device-specific set might
# need to access the common configuration from here (especially when
# overwriting only subsets, e.g. common.config // { services.xserver
# = common.services.xserver // { ... }; }). And since we're exporting
# the default configuration like this we can also export the utility
# functions from this set.

# FIXME Currently the problem is that the merge operator (//)
# overwrites subsets. I.e. {s={a=1;b=2;};}//{s.b=3;} yields
# {s={b=3;};} instead of {s={a=1;b=3;};}. Surely there is some
# nixpkgs library function that can easily merge sets without
# overwriting subsets. Maybe there is even some concept for joining
# sets that represent system configurations?

{ pkgs }:

rec {

  config = {

    ###########
    # general #
    ###########

    imports = [
      # Include the results of the hardware scan.
      # For more hardware-specific settings (and - according to the
      # NixOS user manual - hardware configuration for known
      # hardware), see https://github.com/NixOS/nixos-hardware
      /etc/nixos/hardware-configuration.nix
    ];

    nixpkgs.config.allowUnfree = true;


    ########
    # boot #
    ########

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };


    ######################
    # low-level settings #
    ######################

    time.timeZone = "Europe/Berlin";
    i18n.defaultLocale = "en_US.UTF-8";
    services.logind.lidSwitch = "ignore"; # Also an option: "lock"
    networking = {
      hosts = if builtins.pathExists ./hosts.nix then import ./hosts.nix else {};

      # On desktop managers like Gnome it is enough to enable NetworkManager and
      # add the user to the "networkmanager" group.
      networkmanager.enable = true;
      networkmanager.ethernet.macAddress = "random";
      #networkmanager.backend = "iwd";
      #wireless.iwd.enable = true; # IWD

      # Open ports in the firewall.
      # firewall.allowedTCPPorts = [ ... ];
      # firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      firewall.enable = true;
      #firewall.interfaces.enp9s0.allowedTCPPorts = [ 7878 ];
    };

    # console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    #   useXkbConfig = true; # use xkb.options in tty.
    # };


    ############
    # graphics #
    ############

    services.xserver = {
      enable = true;
      xkb.layout = if utils.choose "neo" then "de" else "us";
      xkb.variant = if utils.choose "neo" then "neo" else "altgr-intl";
      xkb.options = "eurosign:e"; # Also an option: "caps:escape"

      # TODO: unity(d) and/or unityx - https://unityd.org/

      # FIXME: With lightdm+gnome the screen can't be locked (e.g. after waking up from suspend)
      #displayManager.lightdm = {
      #  enable = true;
      #  greeters.slick = {
      #    enable = true;
      #    theme.package = pkgs.yaru-theme;
      #    theme.name = "Yaru";
      #    iconTheme.package = pkgs.humanity-icon-theme;
      #    iconTheme.name = "Humanity-Dark";
      #    cursorTheme.name = "Yaru";
      #    extraConfig = "background=/nix/store/7kgj35gfy6kjd69f5n6xv480sgb5dq63-Ubuntu-13-10-s-Default-Wallpaper-Leaked-384965-2.jpg\n";
      #  };
      #};

      # Don't use Lomiri (formerly Unity8) - it is clearly made for Ubuntu Touch and not for desktops! It's really bad...
      #services.desktopManager.lomiri.enable = true;
    } // (
      let desktop = utils.chooseOrDefault "desktop" "gnome"; in {
        kde = {
          displayManager.sddm.enable = true;
          desktopManager.plasma5.enable = true;
        };
        gnome = {
          displayManager.gdm.enable = true;
          desktopManager.gnome.enable = true;
        };
        i3 = {
          desktopManager.gnome.enable = true;
          windowManager.i3.enable = true;
          windowManager.i3.package = pkgs.i3-rounded;
          windowManager.i3.configFile = ./files/i3_config;
        };
      }."${desktop}"
    );


    #########
    # Sound #
    #########

    # default sound settings are enough right now. They use pipewire and it
    # works for me so far.


    ###########################
    # users and user packages #
    ###########################

    users.groups.laerling.gid = 1000; # same GID and UID as on Ubuntu
    users.users.laerling = {
      isNormalUser = true;
      uid = 1000;
      group = "laerling";
      extraGroups = [
        # - pipewire might require users to be in group "audio"
        # - sudo only works with group "wheel"
        "adbusers" "audio" "networkmanager" "vboxusers" "wheel" "wireshark"
      ];
      packages = with pkgs; let
        gnome-packages = [
          # eog is the old (and better, because it supports saving image
          # rotation) image viewer (the new one is loupe)
          eog ffmpegthumbnailer gnome-tweaks dconf-editor
        ];
        ubuntu-style = [
          # font packages are handled via the fonts.packages option
          humanity-icon-theme ubuntu-themes yaru-theme
        ] ++ (with gnomeExtensions; [ dash-to-dock user-themes ]);
      in [
        # breeze-icons contains icons for kolourpaint
        bc borgbackup breeze-icons cargo curl dig discord drawpile emacs29 ffmpeg
        file firefox gcc gdb gnumake gnupg jq keepassxc killall kolourpaint
        krita lm_sensors man-pages mpv netcat-gnu nmap pavucontrol python3
        tcpdump telegram-desktop thunderbird tor-browser tree unzip wget
        wireshark xxHash whois yt-dlp
      ] ++ gnome-packages ++ ubuntu-style ++ utils.chosenPackages;
    };


    ########################
    # system-wide packages #
    ########################

    # - only bare necessities that are regularly needed for administration stuff
    #   (everything else can be pulled in via nix-shell)
    # - only programs that are allowed to run as root
    environment.systemPackages = with pkgs; [
      bintools efibootmgr gptfdisk screen vim-full ];
      environment.gnome.excludePackages = with pkgs; [
        # loupe is the new and incomplete image viewer. I use eog (see above).
        gnome-tour epiphany geary gnome-calendar gnome-initial-setup
        gnome-music loupe man-pages man-pages-posix totem xterm yelp
      ];


    ###############################
    # other programs and services #
    ###############################

    # E. g. steam, wireshark, ...
    programs.adb.enable = true;
    programs.git = {
      enable = true;
      lfs.enable = true;
    };
    programs.mtr.enable = true;
    programs.steam.enable = utils.choose "steam";
    programs.wireshark.enable = true;
    virtualisation.virtualbox.host.enable = true;


    #########################
    # environment and shell #
    #########################

    environment = {
      etc."mpv/mpv.conf".text = "audio-display=no";
      variables = {
        EDITOR = "vim";
        TERMINAL = "kgx";
        VISUAL = "vim";
      };
    };

    # generate immutable manpage DB
    documentation.man.generateCaches = true;

    # fonts
    fonts.packages = with pkgs; [
      ubuntu-classic ubuntu-sans ubuntu-sans-mono
    ];

  }; # end of config

  utils = rec {

    choose = keyname: chooseOrDefault keyname false;

    # TODO rename to chooseOrCustomDefault (including all occurences)
    # and define chooseOrDefault with default being the NixOS option
    # default value.
    chooseOrDefault = keyname: default: let
      path=./choices.nix;
      choices = import path;
    in if builtins.pathExists path && choices ? "${keyname}"
    then choices."${keyname}" else default;

    # map choices to derivations, returning them as a list
    chosenPackages = let packageForChoice = with pkgs; {
      minecraft = prismlauncher;
      crt = cool-retro-term;
    }; in with builtins; concatMap
    (c: if choose c then [packageForChoice."${c}"] else [])
    (attrNames packageForChoice);

  };

}
