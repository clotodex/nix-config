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
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-gtk" ];
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.gnome-keyring
      ];
    };
  };
}
