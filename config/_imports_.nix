{inputs, ...}: {
  imports = [
    # inputs.agenix-rekey.nixosModules.default
    # inputs.agenix.nixosModules.default
    # inputs.disko.nixosModules.disko
    # inputs.elewrap.nixosModules.default
    # inputs.home-manager.nixosModules.default
    # inputs.impermanence.nixosModules.impermanence
    # inputs.nix-topology.nixosModules.default
    # inputs.nixos-extra-modules.nixosModules.default
    # inputs.nixos-nftables-firewall.nixosModules.default

    ./bluetooth.nix
    ./boot.nix
    ./hardware.nix
    ./inputrc.nix
    ./laptop.nix
    # ./networking.nix
    ./nix.nix
	./sound.nix
  ];
}
