{
  lib,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
  boot.blacklistedKernelModules = [ "nouveau" ];
  services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware = {
    nvidia = {
      modesetting.enable = true;
      nvidiaPersistenced = true;
      nvidiaSettings = true;
      # TODO: check this
      open = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
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
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        libvdpau-va-gl
        vaapiVdpau
        nvidia-vaapi-driver
      ];
    };
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver
}
