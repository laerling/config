{ pkgs ? import <nixpkgs> {} }:

let

  callPackage = path: args: pkgs.callPackage path args;

  ollamaAttrs = rec {

    version = "0.15.2";

    src = pkgs.fetchFromGitHub {
      owner = "ollama";
      repo = "ollama";
      tag = "v${version}";
      hash = "sha256-hfEuVWMmayAO26EV6fu7lRWEL3Es9wyN9sMdm5I+NJE=";
    };

    vendorHash = "sha256-WdHAjCD20eLj0d9v1K6VYP8vJ+IZ8BEZ3CciYLLMtxc=";
  };

  overrideOllama = o: (pkgs.ollama.override o).overrideAttrs ollamaAttrs;

in

{

  discord = callPackage ./discord {};

  nixos-utils = callPackage ./nixos-utils {};

  ollama = overrideOllama {};
  ollama-cpu = overrideOllama { acceleration = false; };
  ollama-rocm = overrideOllama { acceleration = "rocm"; };
  ollama-cuda = overrideOllama { acceleration = "cuda"; };
  ollama-vulkan = overrideOllama { acceleration = "vulkan"; };

}
