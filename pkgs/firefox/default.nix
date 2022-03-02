{ pkgs ? import <nixpkgs> {} }:

with pkgs;
symlinkJoin {
  name = firefox.name + "-touchfriendly";
  inherit (firefox) pname version;
  paths = [ firefox ];
  buildInputs = [ makeWrapper ];
  postBuild = "wrapProgram $out/bin/firefox --set MOZ_USE_XINPUT2 1";
}
