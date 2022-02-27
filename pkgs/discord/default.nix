{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,

  version ? "0.0.17",
}:

let
  inherit (pkgs) callPackage fetchurl;

  src = fetchurl {
    url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
    sha256 = "058k0cmbm4y572jqw83bayb2zzl2fw2aaz0zj1gvg6sxblp76qil";
  };

  meta = with lib; {
    description = "All-in-one cross-platform voice and text chat for gamers";
    homepage = "https://discordapp.com/";
    downloadPage = "https://discordapp.com/download";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };

in

  # use nixpkgs expression if version is at least the one we want
  if lib.strings.versionAtLeast pkgs.discord.version version
  then pkgs.discord else

  callPackage
  "${pkgs.path}/pkgs/applications/networking/instant-messengers/discord/linux.nix"
  {
    inherit src version meta;
    pname = "discord";
    binaryName = "Discord";
    desktopName = "Discord";
  }
