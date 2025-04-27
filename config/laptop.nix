{
  systemd.network.wait-online = {
    enable = false;
    anyInterface = true;
  };

  services = {
    tlp.enable = true;
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
