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
  ];

  hardware = {
    enableRedistributableFirmware = true; # TODO: this does not seem to have any effect
    enableAllFirmware = true;
  };

  services = {
    fwupd.enable = true;
    smartd.enable = true;
    thermald.enable = builtins.elem config.nixpkgs.hostPlatform.system ["x86_64-linux"];
  };
}
