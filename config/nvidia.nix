{
  lib,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
  boot.blacklistedKernelModules = ["nouveau"];
  services.xserver.videoDrivers = lib.mkForce ["nvidia"];

  hardware = {
    nvidia = {
      modesetting.enable = true;
      nvidiaPersistenced = true;
      nvidiaSettings = true;
      # TODO: check this
      open = true;
      powerManagement.enable = true;
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        nvidia-vaapi-driver
      ];
    };
  };
}
