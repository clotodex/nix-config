{
  config,
  inputs,
  lib,
  minimal,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    types
    optionalAttrs
    ;
in
{
  config = {
    # Needed for gtk
    programs.dconf.enable = true;
    # Required for gnome3 pinentry
    services.dbus.packages = [ pkgs.gcr ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Enable the X11 windowing system.
    services.xserver.enable = false;
    programs.hyprland = {
      enable = true;
      # set the flake package
      package = inputs.hyprland-plugins.inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage =
        inputs.hyprland-plugins.inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
    #programs.waybar.enable = true;

    # We actually use the home-manager module to add the actual portal config,
    # but need this so relevant implementations are found
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
    ];

    services.displayManager.enable = true;
    programs.uwsm = {
      enable = true;
      waylandCompositors.hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland";
        binPath = lib.getExe inputs.hyprland-plugins.inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      };
    };

  };
}
