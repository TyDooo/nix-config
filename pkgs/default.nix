{pkgs ? import <nixpkgs> {}}: {
  mover = pkgs.callPackage ./mover {};
  sf100linux = pkgs.callPackage ./sf100linux.nix {};
  sonarr-v4 = pkgs.callPackage ./sonarr-v4 {};
}
