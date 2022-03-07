{
  pkgs ? import <nixpkgs> {},
  system ? builtins.currentSystem,
}:

let

  # Link from here: https://nixos.wiki/wiki/NixOS_Generations_Trimmer
  trim-generations = builtins.fetchurl "https://gist.githubusercontent.com/Bondrake/27555c9d02c2882fd5e32f8ab3ed620b/raw/e1e5dd68761a7f7e6a253fcb64905466104b9df9/trim-generations.sh";

in

  # TODO reicht nicht auch symlinkJoin oder so?
  with pkgs;
  stdenv.mkDerivation rec {

    name = "nixos-utils";
    inherit system;

    # scripts
    scriptDir = with builtins; path {
      path = ./scripts;
      name = "${name}-scripts";
      filter = name: type: type != "directory" && (match ".*~" name) == null;
    };
    otherScripts = [ trim-generations ];

    # only install and fixup
    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin/
      for script in $scriptDir/* $otherScripts; do
        target=$out/bin/$(stripHash $script|sed 's/\.sh$//')
        cp $script $target
        chmod +x $target
      done
    '';

    # TODO: Inject PATH (in fixup phase?)
    fixupPhase = ''
      for script in $out/bin/*; do
        patchShebangs $script
      done
    '';
  }
