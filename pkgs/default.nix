{ pkgs ? import <nixpkgs> {} }:

let
  callPackage = path: args: pkgs.callPackage path ({ inherit pkgs; } // args);
in

{

  discord = callPackage ./discord {};

  firefox = callPackage ./firefox {}; # touch-friendly

  nixos-utils = callPackage ./nixos-utils {};

}
