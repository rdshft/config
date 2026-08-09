{
  description = "sean's nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        minotaur = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./nixos/minotaur

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.sean = import ./home-manager/minotaur.nix;
            }
          ];
          specialArgs = { inherit inputs; };
        };

        ceres = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./nixos/ceres

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.sean = import ./home-manager/ceres.nix;
            }
          ];
          specialArgs = { inherit inputs; };
        };
      };

      packages.${system} = import ./packages { inherit pkgs; };
    };
}
