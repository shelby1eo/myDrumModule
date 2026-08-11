# nix develop


{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
  in
  {
    # importing package example
    packages."x86_64-linux".default =
      pkgs.callPackage (import ./shell.nix) {};

    # defining directly here pkgs
    # devShells."x86_64-linux".default = pkgs.mkShell {
    #   packages = [ pkgs.nodejs pkgs.python3 ];
    #   inputsFrom = [ pkgs.bat ];
    # };
  };
}
