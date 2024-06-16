# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, pkgs,  ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
	  ./config
	  #./config/nix.nix
	  # inputs.home-manager.nixosModule.home-manager
    ];


  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  #i18n.defaultLocale = "C.UTF-8";
  console = {
  #   font = "Lat2-Terminus16";
    keyMap = "de-latin1-nodeadkeys";
    font = "ter-v28n";
    packages = [pkgs.terminus_font];
  #   useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = false;
  programs.hyprland.enable = true;
  programs.waybar.enable = true;



  # home-manager = {
  #   extraSpecialArgs = { inherit inputs; };
  #   users= {
  #   # "clotodex" = import ./home.nix;
  #   clotodex= {
  #   wayland.windowManager.hyprland = {
  #   	enable = true;
  #   	# ...
  #   	plugins = [
  #   	inputs.Hyprspace.packages.${pkgs.system}.Hyprspace
  #   	# ...
  #   	];
  #   };
  #   };
  #   };
  # };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/clotodex/nix-config/";
  };


  # Enable CUPS to print documents.
  services.printing.enable = true;


  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  programs.fish.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    kitty
    borgbackup
    tree
    fzf
    ripgrep
    (python311.withPackages (ps: with ps; [
      tqdm
    ]))
    acpi
    git
    killall
    bc
    wlr-randr
    hypridle
	dua
	duf
	colordiff
	diffutils
	difftastic
	rustc
	cargo
	pkgs.kitty.terminfo
	devenv
  ];
}

