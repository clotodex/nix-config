{
  description = "A very basic flake";

  inputs = {
    nixpkgs-2311.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      #url = "github:hyprwm/Hyprland/v0.41.1?submodules=1";
      url = "git+https://github.com/hyprwm/Hyprland/?submodules=1"; #&rev=882f7ad7d2bbfc7440d0ccaef93b1cdd78e8e3ff";
      #url = "git+https://github.com/hyprwm/Hyprland/?submodules=1&rev=e4abf26069b4d43c8f6ad6b3dfb56c952abb38c2";
      #inputs.hyprutils.url = "github:hyprwm/hyprutils/v0.5.2";
      #url = "github:hyprwm/Hyprland";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #Hyprspace = {
    #  url = "github:KZDKM/Hyprspace";
    #  #url = "github:ReshetnikovPavel/Hyprspace";

    #  # Hyprspace uses latest Hyprland. We declare this to keep them in sync.
    #  inputs.hyprland.follows = "hyprland";
    #};
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-extra-modules = {
      url = "github:oddlama/nixos-extra-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    pyprland = {
      url = "github:hyprland-community/pyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    naersk.url = "github:nix-community/naersk";
    earbuds-src = {
      url = "github:JojiiOfficial/LiveBudsCli?rev=1690eab9116dc9fb576372a7cd234cc28de0a112";
      flake = false;
    };
    figma-agent-src = {
      url = "github:neetly/figma-agent-linux";
      flake = false;
    };
    waybar-custom-modules-src = {
      url = "github:LawnGnome/waybar-custom-modules?rev=5e7713180e52285e3db169ba7d448ab61215ac41";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
      };
    };
  in {
    nixosConfigurations = {
      kotn = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit system;
          inherit inputs;
        };
        modules = [
          ./hardware-configuration.nix
          ./config
          # inputs.home-manager.nixosModule.default
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {inherit inputs;};
            home-manager.sharedModules = [
              # inputs.nixos-extra-modules.homeManagerModules.default
              inputs.nix-index-database.hmModules.nix-index
              inputs.nixvim.homeManagerModules.nixvim
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
