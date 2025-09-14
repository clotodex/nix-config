{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./hyprland
    ./ashell.nix
  ];

  home.packages = with pkgs; [
    (grimblast.override { hyprland = null; })
    swaylock
    hyprpicker
    wl-clipboard
    swww
    rofi
    libnotify
    (hyprshade.override { hyprland = null; })
  ];

  services.hypridle = {
    enable = false;
    settings = {
      listener = [
        {
          timeout = 60; # in seconds
          on-timeout = "hyprctl dispatch dpms off"; # command to run when timeout has passed
          on-resume = "hyprctl dispatch dpms on"; # command to run when activity is detected after timeout has fired.
        }
      ];
    };
  };

  xdg.portal = {
    enable = lib.mkForce true;
    xdgOpenUsePortal = true;
    config.common = {
      default = [ "gtk" "hyprland" ];
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
}
