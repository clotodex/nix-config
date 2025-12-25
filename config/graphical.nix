{
  config,
  inputs,
  lib,
  minimal,
  pkgs,
  ...
}:
{
  config = {
    # Needed for gtk
    programs.dconf.enable = true;
    # Required for gnome3 pinentry
    services.dbus.packages = [ pkgs.gcr ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Enable the X11 windowing system.
    services.xserver.enable = false;

    # We actually use the home-manager module to add the actual portal config,
    # but need this so relevant implementations are found
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
    ];

    services.displayManager.enable = true;

  };
}
