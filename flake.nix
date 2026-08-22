{
  description = "dotfiles - linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, home-manager, nixpkgs }:
    let
      # The one username line to change if this isn't your machine.
      user = "ivolej01";
      # Change to "aarch64-linux" if you are on ARM (e.g. Raspberry Pi, Asahi).
      system = "x86_64-linux";
    in
    {
      homeConfigurations."linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit user; };
        modules = [
          ./home.nix
        ];
      };
    };
}
