{
  description = "MEOW!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    impermanence.url = "github:nix-community/impermanence";
    home-manager.url = "github:nix-community/home-manager";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nix-flatpak,
    nixpkgs-stable,
    nixpkgs,
    impermanence,
    home-manager,
  }: {
    nixosConfigurations.flake = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = { inherit inputs; };

      modules = [

        nix-flatpak.nixosModules.nix-flatpak
        impermanence.nixosModules.impermanence
        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.vulkce = import ./home-manager/home.nix;
        }
      ];
    };
  };
}
