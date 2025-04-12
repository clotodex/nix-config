{inputs, pkgs, ...}: {
  imports = [
    # inputs.agenix-rekey.nixosModules.default
    # inputs.agenix.nixosModules.default
    # inputs.disko.nixosModules.disko
    # inputs.elewrap.nixosModules.default
    inputs.home-manager.nixosModules.default
    # inputs.impermanence.nixosModules.impermanence
    # inputs.nix-topology.nixosModules.default
    # inputs.nixos-extra-modules.nixosModules.default
    # inputs.nixos-nftables-firewall.nixosModules.default

    ./bluetooth.nix
    ./boot.nix
    ./fonts.nix
    ./general.nix
    ./graphical.nix
    ./hardware.nix
    ./inputrc.nix
    ./laptop.nix
    ./networking.nix
    #./nvidia.nix
    ./nix.nix
    ./sound.nix
    ./user.nix
    ./virtualization.nix
    ./print.nix
    ./packages.nix
    ./itsec.nix
  ];


  nixpkgs.overlays =
    (import ../pkgs/default.nix { inherit inputs pkgs; })
    ++ [
      inputs.nixos-extra-modules.overlays.default
      inputs.nixvim.overlays.default
      #inputs.wired-notify.overlays.default
    ];
}
