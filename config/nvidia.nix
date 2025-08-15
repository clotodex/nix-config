{
  lib,
  pkgs,
  config,
  ...
}:
let
  nvidia_driver = config.boot.kernelPackages.nvidiaPackages.beta;
in
{
  boot.blacklistedKernelModules = [ "nouveau" ];
  services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        nvidia-vaapi-driver
      ];
    };
    nvidia = {
      modesetting.enable = true;
      open = true;
      powerManagement.enable = true;
    };
  };
}

/*
    boot.blacklistedKernelModules = [ "nouveau" ];
    services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];

      #nixpkgs.config.packageOverrides = pkgs: {
      #  intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
      #};
    hardware = {
      nvidia = {
        modesetting.enable = true;
        nvidiaPersistenced = true;
        nvidiaSettings = true;
        # TODO: check this
        open = true;
        powerManagement.enable = true;
        powerManagement.finegrained = true;
        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };
          #intelBusId = "PCI:0:2:0";
          #nvidiaBusId = "PCI:1:0:0";
        };
        package = nvidia_driver;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
          # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
          #(intel-vaapi-driver.override { enableHybridCodec = true; })
          libvdpau-va-gl
          vaapiVdpau
          nvidia-vaapi-driver
        ];
      };
    };
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
      #VK_DRIVER_FILES = "${pkgs.mesa.out}/share/vulkan/icd.d/intel_icd.x86_64.json:${nvidia_driver.out}/share/vulkan/icd.d/nvidia_icd.x86_64.json";
      #VK_ICD_FILENAMES="/nix/store/ig8h5hjy3s9lfhi75zc64acmyzr8zzyd-mesa-25.1.6/share/vulkan/icd.d/intel_icd.x86_64.json
    }; # Force intel-media-driver
  }
*/
