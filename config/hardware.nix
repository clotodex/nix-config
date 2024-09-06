# Configuration for actual physical machines
{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    inputs.nixos-hardware.nixosModules.asus-zephyrus-gu603h
    inputs.nixos-hardware.nixosModules.asus-battery
    #inputs.nixos-hardware.nixosModules.common-gpu-nvidia
  ];

  hardware = {
    enableRedistributableFirmware = true; # TODO: this does not seem to have any effect
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  services = {
    fwupd.enable = true;
    smartd.enable = true;
    thermald.enable = builtins.elem config.nixpkgs.hostPlatform.system ["x86_64-linux"];
  };
}
