{
  systemd.network.wait-online = {
    enable = false;
    anyInterface = true;
  };

  services = {
    tlp = {
      enable = true;
      settings = {
        #CPU_SCALING_GOVERNOR_ON_AC = "performance";
        #CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        #CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        #CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        #CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 40;

        RUNTIME_PM_ON_AC = "auto";
        RUNTIME_PM_DRIVER_DENYLIST = "mei_me";
        SOUND_POWER_SAVE_ON_AC = 1;
        SOUND_POWER_SAVE_ON_BAT = 1;
        # RUNTIME_PM_ENABLE -> pci id

        #Optional helps save long term battery health
        #START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
        #STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

      };
    };
    upower.enable = true;
    physlock.enable = true;
    logind = {
      lidSwitch = "ignore";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "ignore";
      extraConfig = ''
        HandlePowerKey=suspend
        HandleSuspendKey=suspend
        HandleHibernateKey=suspend
        PowerKeyIgnoreInhibited=yes
        SuspendKeyIgnoreInhibited=yes
        HibernateKeyIgnoreInhibited=yes
      '';
    };
  };
}
