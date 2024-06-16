{inputs, ...}: {
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
    ./nix.nix
	./sound.nix
	./user.nix
	./virtualization.nix
  ];

  nixpkgs.overlays =
              import ../pkgs/default.nix
              ++ [
                inputs.nixos-extra-modules.overlays.default
                inputs.nixvim.overlays.default
                #inputs.wired-notify.overlays.default
              ];
}
