{
  description = "dotfiles - linux";

  inputs = {
    # Same release cycle as main, but the Linux branch: there is no
    # nixpkgs-26.05-linux, the release branch of 26.05 is nixos-26.05.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, home-manager, nixpkgs }:
    let
      # The one username line to change if this isn't your machine.
      # bootstrap.sh offers to rewrite this for you if your Linux username differs.
      user = "ivolejon";
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
