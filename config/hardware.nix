# Configuration for actual physical machines
{
  config,
  lib,
  ...
}: {
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
