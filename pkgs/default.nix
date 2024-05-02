{ pkgs ? import <nixpkgs> {} }:

let
  callPackage = path: args: pkgs.callPackage path ({ inherit pkgs; } // args);
in

{

  discord = callPackage ./discord {};

  nixos-utils = callPackage ./nixos-utils {};

}
