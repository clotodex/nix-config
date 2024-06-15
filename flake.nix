{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
	home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
	hyprland ={
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    Hyprspace = {
      url = "github:KZDKM/Hyprspace";

      # Hyprspace uses latest Hyprland. We declare this to keep them in sync.
      inputs.hyprland.follows = "hyprland";
    };
	nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
	nixos-extra-modules = {
      url = "github:oddlama/nixos-extra-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    pyprland.url = "github:hyprland-community/pyprland";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:

	let
	  system = "x86_64-linux";

	  pkgs = import nixpkgs {
	  	inherit system;

	  	config = {
	  		allowUnfree = true;
		};

	  };
	in
	{

	nixosConfigurations = {
		kotn = nixpkgs.lib.nixosSystem {
			specialArgs = { inherit system; inherit inputs; };
			modules = [
				./configuration.nix
				# inputs.home-manager.nixosModule.default
				home-manager.nixosModules.home-manager
				{
					home-manager.extraSpecialArgs = { inherit inputs ; };
					home-manager.sharedModules = [
						# inputs.nixos-extra-modules.homeManagerModules.default
						inputs.nix-index-database.hmModules.nix-index
						# inputs.nixvim.homeManagerModules.nixvim
					];
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					#home-manager.users.clotodex = {
					#	imports = [
					#	./home.nix
					#	./shell/default.nix
					#];};
				}
			];
		};

	};
	};
}
