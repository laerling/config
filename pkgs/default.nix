{ pkgs ? import <nixpkgs> {} }:

with pkgs;
{

  discord = callPackage ./discord {};

}
