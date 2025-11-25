{
  description = "A very basic flake";

  inputs = {
    #nixpkgs-2311.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland"; # /v0.52.1"; # ?rev=2794f485cb5d52b3ff572953ddcfaf7fd3c25182"; # /v0.49.0";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins"; # /scroll-overview"; # /v0.49.0-fix";
      #inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprland.follows = "hyprland";
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

    nixvim = {
      url = "github:nix-community/nixvim";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    naersk.url = "github:nix-community/naersk";
    #crane.url = "github:ipetkov/crane";
    earbuds-src = {
      url = "github:JojiiOfficial/LiveBudsCli?rev=1690eab9116dc9fb576372a7cd234cc28de0a112";
      flake = false;
    };
    ashell = {
      #url = "github:MalpenZibo/ashell";
      url = "github:clotodex/ashell-iwd/feature/niri-support";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    project-chooser-src = {
      url = "github:clotodex/project-chooser";
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

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
        };
      };

      shared_modules = [
        ./config
        # inputs.home-manager.nixosModule.default
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.sharedModules = [
            # inputs.nixos-extra-modules.homeManagerModules.default
            inputs.nix-index-database.homeModules.nix-index
            inputs.nixvim.homeModules.nixvim
          ];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          #home-manager.users.clotodex = {
          #	imports = [
          #	./home.nix
          #	./shell/default.nix
          #];};
          custom.hardware = {
            isAsus = true;
          };
        }
      ];
    in
    {
      nixosConfigurations = {
        kotn = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit inputs;
          };
          modules = shared_modules ++ [
            {
              networking.hostName = "kotn";
              custom.hardware.enableNvidia = true;
            }
            inputs.nixos-hardware.nixosModules.asus-zephyrus-gu603h
            inputs.nixos-hardware.nixosModules.asus-battery
            ./hardware-configuration.nix
          ];
        };

        flipsy = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit inputs;
          };
          modules = shared_modules ++ [
            {
              networking.hostName = "flipsy";
              # intel alder-lake gpu
              hardware.intelgpu.vaapiDriver = "intel-media-driver";

              hardware.graphics = {
                enable = true;
                extraPackages = with pkgs; [
                  # Required for modern Intel GPUs (Xe iGPU and ARC)
                  intel-media-driver # VA-API (iHD) userspace
                  vpl-gpu-rt # oneVPL (QSV) runtime
                  intel-compute-runtime # OpenCL (NEO) + Level Zero for Arc/Xe
                  # libvdpau-va-gl       # Only if you must run VDPAU-only apps
                ];
              };

              security.pam.services.swaylock = { };

              environment.sessionVariables = {
                LIBVA_DRIVER_NAME = "iHD"; # Prefer the modern iHD backend
                # VDPAU_DRIVER = "va_gl";      # Only if using libvdpau-va-gl
              };
              # alder-lake fix
              boot.kernelParams = [ "i915.force_probe=46a6" ];

              nixpkgs.overlays = [ inputs.niri.overlays.niri ];
              # for now for cache for cache
              programs.niri.enable = true;
              programs.niri.package = pkgs.niri;

              #environment.systemPackages = [
              #  pkgs.xwayland-satellite
              #];

            }
            inputs.niri.nixosModules.niri

            inputs.nixos-hardware.nixosModules.asus-battery
            inputs.nixos-hardware.nixosModules.common-pc-laptop
            inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
            inputs.nixos-hardware.nixosModules.common-cpu-intel # alder-lake
            ./hardware-configuration_flipsy.nix
          ];
        };
      };
    };
}
