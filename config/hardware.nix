# Configuration for actual physical machines
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  custom = {
    hardware = {
      isAsus = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the hardware is an Asus laptop.";
      };
      enableNvidia = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable Nvidia GPU support.";
      };
    };
  };
in
{
  options.custom = custom;
  config = {
    # replicate both options as well as nixos module settings to home-manager
    home-manager.sharedModules = [
      {
        options.custom = custom;
      }
      {
        config.custom = config.custom;
      }
    ];

    hardware = {
      enableRedistributableFirmware = true; # This switches on other things if you have nixos-hardware
      enableAllFirmware = true;
    };

    #boot.kernelParams = [ "i915.force_probe=46a6" ];

    services = {
      fwupd.enable = true;
      smartd.enable = true;
      thermald.enable = true; # builtins.elem config.nixpkgs.hostPlatform.system ["x86_64-linux"];
    };

    #services.supergfxd.enable = true;
    services.asusd.enable = lib.mkIf config.custom.hardware.isAsus true;

    #systemd.services.no-sdcard = {

    #  serviceConfig = {
    #    Description = "removes pci sdcard upon boot";
    #    Type = "oneshot";
    #    User = "root";
    #    RemainAfterExit = true;
    #    ExecStart = lib.getExe (
    #      pkgs.writeShellApplication {
    #        name = "remove-sd-pci";
    #        text = ''
    #          echo 1 > /sys/bus/pci/devices/0000:2d:00.0/remove
    #        '';
    #      }
    #    );
    #  };

    #  wantedBy = [ "multi-user.target" ];
    #};

    #services.supergfxd.settings = {
    #    # mode = "Integrated";
    #    vfio_enable = true;
    #    vfio_save = false;
    #    always_reboot = false;
    #    no_logind = false;
    #    logout_timeout_s = 20;
    #    hotplug_type = "Asus";
    #  };
    #};
    #systemd.services.supergfxd.path = [ pkgs.kmod pkgs.pciutils ];
  };
}
