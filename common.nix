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
    nix.settings.experimental-features = [
      "flakes"
      "nix-command"
    ];


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
    services.logind.settings.Login.HandleLidSwitch = "ignore"; # Also an option: "lock"


    ##############
    # networking #
    ##############

    networking = {
      hosts = if builtins.pathExists ./hosts.nix then import ./hosts.nix else {};

      # On desktop managers like Gnome it is enough to enable NetworkManager and
      # add the user to the "networkmanager" group.
      networkmanager.enable = true;

      # firewall (no need to manually open services.openssh.ports)
      firewall.enable = true;
    };


    ############
    # graphics #
    ############

    services.xserver = builtins.trace "TODO: Finish Unity desktop" {
      enable = true;
      xkb.layout = if utils.choose "neo" then "de" else "us";
      xkb.variant = if utils.choose "neo" then "neo" else "altgr-intl";
      xkb.options = "eurosign:e"; # Also an option: "caps:escape"

      # drawing tablet driver
      wacom.enable = true;

      # TODO: unity(d) and/or unityx - https://unityd.org/
      # Don't use Lomiri (formerly Unity8) - it is clearly made for Ubuntu Touch and not for desktops! It's really bad...

      # TODO finish setting up and customizing xfce
      # - key store (e. g. for LUKS keys of external drives)
      # - bluetooth support
      # - fonts from flake into own derivation
      # - explorer/thunar += tree view on the left
      # - start menu
      # - learn shortcuts (maximize, minimize, show desktop, ...)
      # - set that one-pixel-stroke font for task bar items and explorer
      # - set correct font for start button, if possible
      # - browser - Pale Moon? Librewolf?
      # - make derivation from flake for fonts
      # - icons (currently copied to ~/.icons/) from flake into own derivation
      desktopManager.xfce.enable = true;
      desktopManager.xterm.enable = false;

    };


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

        # packages I always want that aren't tied to any particular ecosystem
        basic-packages = [
          bc borgbackup cargo chromium curl dig discord drawpile emacs30 feh
          ffmpeg file gcc gdb ghc glibcInfo gnumake gnupg graphviz htop jq
          keepassxc killall krita libreoffice librewolf lm_sensors man-pages
          mpv netcat-gnu nmap pureref python3 qdirstat tcpdump telegram-desktop
          thunderbird tor-browser unzip upscayl vivaldi wget whois wireshark
          yt-dlp zip
        ];

        # here I group ecosystem-specific packages by the ecosystem
        # they come from (usually desktop environments)
        ecosystem-packages = {

          gnome = [
            dconf-editor ffmpegthumbnailer gnome-screenshot gnome-system-monitor gnome-tweaks
          ];

          kde = with kdePackages; [
            # breeze-icons contains icons for kolourpaint
            breeze-icons kolourpaint
          ];

          xfce = with xfce; [
            # Windows 95/98/2000 theming
            # This flake is a fork from "github:salvatorecriscioneweb/chicago95-nix"
            # alternative: "github:rice-cracker-dev/chicago95-nix"
            (utils.flakeDefault "github:laerling/chicago95-nix")
            #FIXME (utils.flakePackage "github:laerling/chicago95-nix" "chicago95-icons")
            xfce4-whiskermenu-plugin # with chicago95 it looks like the Win95 start menu

            # other programs that for some reason need to be specified manually
            blueman # bluetooth manager
            xfce4-systemload-plugin # system monitor
            xreader # document viewer (PDF etc.)
          ];

          ubuntu = [
            # font packages are handled via the fonts.packages option
            humanity-icon-theme ubuntu-themes yaru-theme
          ] ++ (with gnomeExtensions; [
            dash-to-dock user-themes
          ]);
        };

        ecosystem-packages-list = with builtins; foldl' (a: b: a ++ b) [] (attrValues ecosystem-packages);

        secret-packages = let path = ./secrets/default.nix;
        in if builtins.pathExists path then import path pkgs else [];

        # packages I need for a while but don't need anymore at some point in the future
        temporary-packages = [ veracrypt ];

      in basic-packages ++ ecosystem-packages-list ++ secret-packages ++ utils.chosenPackages ++ temporary-packages;
    };


    ########################
    # system-wide packages #
    ########################

    # - only bare necessities that are regularly needed for administration stuff
    #   (everything else can be pulled in via nix-shell)
    # - only programs that are allowed to run as root
    environment.systemPackages = with pkgs; [
      bintools efibootmgr gptfdisk screen tree vim-full xxHash
    ];
    environment.gnome.excludePackages = with pkgs; [
      # loupe is the new and incomplete image viewer. I use eog (see above).
      epiphany geary gnome-calendar gnome-console gnome-initial-setup
      gnome-music gnome-tour loupe man-pages man-pages-posix totem xterm yelp
    ];


    #########################
    # programs and services #
    #########################

    # E. g. steam, wireshark, ...
    programs.adb.enable = true;
    programs.git = {
      enable = true;
      lfs.enable = true;
    };
    # Needed for pinentry program, which is needed to decrypt files.
    # If it doesn't work, restart the program (it's not in a systemd unit).
    programs.gnupg.agent.enable = true;
    # enable classic Gnome terminal instead of kgx - needs adjustment of
    # gnome.excludePackages and $TERMINAL
    programs.gnome-terminal.enable = true;
    programs.mtr.enable = true;
    programs.steam.enable = utils.choose "steam";
    programs.wireshark.enable = true;
    services.gnome.localsearch.enable = false;
    virtualisation.virtualbox.host.enable = true;


    #########################
    # environment and shell #
    #########################

    environment = {
      etc."mpv/mpv.conf".text = "audio-display=no";
      interactiveShellInit = ''
        function h {
          $@ --help |& less -SR
        }
        alias j="jobs"
        alias gb="git branch -va"
        alias gf="git fetch --all --prune"
        alias gl="git list"
        alias gla="git list --all --graph --oneline"
        alias gp="git pull"
        alias gs="git status"
      '';
      variables = {
        EDITOR = "vim";
        TERMINAL = "gnome-terminal";
        VISUAL = "vim";
      };
    };

    # generate immutable manpage DB
    documentation.man.generateCaches = true;

    # fonts
    # to view fonts use e. g. fontpreview
    fonts.packages = with pkgs; [
      ubuntu-classic ubuntu-sans ubuntu-sans-mono
      liberation_ttf libertinus times-newer-roman
      terminus_font # similar to VGA font, but... also bitmap apparently...
      uni-vga # unicode VGA font

      # Windows 95/98/2000 theming
      #FIXME (utils.flakePackage "github:laerling/chicago95-nix" "chicago95-fonts")
    ];

  }; # end of config

  utils = rec {

    # function to install a given package from a flake
    flakePackage = ref: pkg: (builtins.getFlake ref).packages."${builtins.currentSystem}"."${pkg}";

    # function to install the default package from a flake
    flakeDefault = ref: flakePackage ref "default";

    # Merge sets recursively, i. e. without overriding subsets
    mergeSets = let m = s1: s2: with builtins;
      let s2-merged-into-s1 = mapAttrs (n: v_s1:
        if s2 ? "${n}" then (
          let v_s2 = s2."${n}"; in
          if typeOf v_s1 == "set" && typeOf v_s2 == "set"
          # recursively merge sets
          then m v_s1 v_s2
          # for all other types, s2 overrides s1
          else v_s2
        ) else v_s1) s1;
      in s2 // s2-merged-into-s1; # add elements that are in s2 but not in s1
    in m;

    # merge a set s2 with a subset of a given set s1, even if it doesn't exist
    merge = s1: name: s2: if s1 ? name then mergeSets s1."${name}" s2 else s2;

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
      inherit ollama;
    }; in with builtins; concatMap
    (c: if choose c then [packageForChoice."${c}"] else [])
    (attrNames packageForChoice);

  };

}
