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
    VK_DRIVER_FILES="${pkgs.mesa.out}/share/vulkan/icd.d/intel_icd.x86_64.json:${pkgs.nvidia.out}/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    #VK_ICD_FILENAMES="/nix/store/ig8h5hjy3s9lfhi75zc64acmyzr8zzyd-mesa-25.1.6/share/vulkan/icd.d/intel_icd.x86_64.json
  }; # Force intel-media-driver
}
