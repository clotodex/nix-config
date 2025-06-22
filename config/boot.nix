{
  config,
  lib,
  pkgs,
  ...
}:
{
  #boot.mode = "efi";

  boot = {
    supportedFilesystems = [ "ntfs" ];

    modprobeConfig.enable = true;
    extraModprobeConfig = ''
      blacklist rtsx_pci
      blacklist rtsx_pci_sdmmc
      install rtsx_pci /bin/true
      install rtsx_pci_sdmmc /bin/true
    '';

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      systemd = {
        enable = true;
        # TODO: good idea? targets.emergency.wants = ["network.target" "sshd.service"];
        extraBin.ip = "${pkgs.iproute2}/bin/ip";
        extraBin.ping = "${pkgs.iputils}/bin/ping";
        extraBin.cryptsetup = "${pkgs.cryptsetup}/bin/cryptsetup";
        # Give me a usable shell please
        users.root.shell = "${pkgs.bashInteractive}/bin/bash";
        storePaths = [ "${pkgs.bashInteractive}/bin/bash" ];
      };
    };

    # NOTE: Add "rd.systemd.unit=rescue.target" to debug initrd
    kernelParams = [ "log_buf_len=16M" ]; # must be {power of two}[KMG]
    tmp.useTmpfs = true;

    loader = {
      timeout = lib.mkDefault 2;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # console.earlySetup = true;
  };
}
