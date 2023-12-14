{pkgs ? import <nixpkgs> {}}: rec {
  sf100linux = pkgs.callPackage ./sf100linux.nix {};
}
