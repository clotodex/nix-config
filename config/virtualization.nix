{
  config,
  lib,
  ...
}:
{
  virtualisation.docker = {
    enable = true;
    enableNvidia = false; # TODO:
    autoPrune.enable = true;
    # TODO: extraOptions
    enableOnBoot = false;
    daemon.settings.features.cdi = true;
  };

  users.users."clotodex".extraGroups = [ "docker" ];
  hardware.nvidia-container-toolkit.enable = lib.mkIf config.custom.hardware.enableNvidia true;
}
