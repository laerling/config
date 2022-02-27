{
  pkgs ? import <nixpkgs> {},
  system ? builtins.currentSystem,
}:

let
  # Link from here: https://nixos.wiki/wiki/NixOS_Generations_Trimmer
  trim-generations = builtins.fetchurl "https://gist.githubusercontent.com/Bondrake/27555c9d02c2882fd5e32f8ab3ed620b/raw/e1e5dd68761a7f7e6a253fcb64905466104b9df9/trim-generations.sh";
in

derivation {
  name = "nixos-utils";
  inherit system;
  builder = "${pkgs.bash}/bin/bash";
  args = [ "-c" (with pkgs; ''
    ${coreutils}/bin/mkdir -p $out/bin/
    ${coreutils}/bin/cp ${trim-generations} $out/bin/trim-generations
    ${coreutils}/bin/chmod +x $out/bin/trim-generations
  '') ];
}
