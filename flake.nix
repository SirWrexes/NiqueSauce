{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-colors,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs' = nixpkgs-unstable.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        houston = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit nix-colors pkgs'; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "old";
              home-manager.users.wrexes = ./home;
              home-manager.extraSpecialArgs = { inherit nix-colors pkgs'; };
            }
          ];
        };
      };
    };
}
