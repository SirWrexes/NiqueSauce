{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-colors,
      sops-nix,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      inherit (lib.attrsets) mergeAttrsList;

      pkgs' = nixpkgs-unstable.legacyPackages.${system};

      system = "x86_64-linux";

      getHostDefaults =
        name:
        import ./system/hosts/configure.nix {
          inherit name;
          flake = ./.;
        };

      getHostConfig = name: ./hosts + "/${name}/default.nix";

      getHostModules =
        name:
        map (x: x name) [
          getHostDefaults
          getHostConfig
        ];

      getHostOsConfig =
        {
          modules ? [ ],
          ...
        }@globals:
        name: {
          ${name} = lib.nixosSystem (
            globals
            // {
              modules = getHostModules name ++ modules;
            }
          );
        };

      forHosts = hosts: globals: mergeAttrsList (map (getHostOsConfig globals) hosts);
    in
    {
      nixosConfigurations = forHosts [ "houston" "voyager" ] {
        inherit system;
        specialArgs = { inherit pkgs' sops-nix nix-colors; };
        modules = [
          ./system
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "old";
              users.wrexes = ./home;
              extraSpecialArgs = {
                inherit pkgs' sops-nix nix-colors;
                root = self;
              };
            };
          }
        ];
      };
    };
}
