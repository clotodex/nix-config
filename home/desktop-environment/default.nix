{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./niri.nix
    ./hyprland
    ./ashell.nix
  ];

  options.custom.compositor = {
    enabledCompositors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "hyprland"
        "niri"
      ];
      description = "List of enabled compositors.";
    };
  };

  config = {

    home.packages = with pkgs; [
      swaylock
      wl-clipboard
      dragon-drop
      swww
      rofi
      libnotify
    ];

    xdg.portal = {
      enable = lib.mkForce true;
      xdgOpenUsePortal = true;
      config.common = {
        default = [
          "gtk"
          "hyprland"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-gtk" ];
      };
      extraPortals = [
        # pkgs.xdg-desktop-portal-hyprland
        # pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
        # Added by hyprland
        # inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
      ];
    };
  };
}
