{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./niri.nix
    ./ashell.nix
  ];

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
