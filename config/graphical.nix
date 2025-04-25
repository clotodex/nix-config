{
  config,
  inputs,
  lib,
  minimal,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkOption
    types
    optionalAttrs
    ;
in {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  config = {
    # Needed for gtk
    programs.dconf.enable = true;
    # Required for gnome3 pinentry
    services.dbus.packages = [pkgs.gcr];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Enable the X11 windowing system.
    services.xserver.enable = false;
    programs.hyprland = {
      enable = true;
      # set the flake package
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
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
        binPath = lib.getExe inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      };
    };


    stylix = {
      # I want to choose what to style myself.
      autoEnable = false;
      image = config.lib.stylix.pixel "base00";

      polarity = "dark";

      # onedark
      # base16Scheme = {
      #   base00 = "#282c34";
      #   base01 = "#353b45";
      #   base02 = "#3e4451";
      #   base03 = "#545862";
      #   base04 = "#565c64";
      #   base05 = "#abb2bf";
      #   base06 = "#b6bdca";
      #   base07 = "#c8ccd4";
      #   base08 = "#e06c75";
      #   base09 = "#d19a66";
      #   base0A = "#e5c07b";
      #   base0B = "#98c379";
      #   base0C = "#56b6c2";
      #   base0D = "#61afef";
      #   base0E = "#c678dd";
      #   base0F = "#9378de";
      # };

      # based on decaycs-dark, normal variant
      base16Scheme = {
        base00 = "#101419";
        base01 = "#171b20";
        base02 = "#21262e";
        base03 = "#242931";
        base04 = "#485263";
        base05 = "#b6beca";
        base06 = "#dee1e6";
        base07 = "#e3e6eb";
        base08 = "#e05f65";
        base09 = "#f9a872";
        base0A = "#f1cf8a";
        base0B = "#78dba9";
        base0C = "#74bee9";
        base0D = "#70a5eb";
        base0E = "#c68aee";
        base0F = "#9378de";
      };

      ## based on decaycs-dark, bright variant
      #base16Scheme = {
      #  base00 = "#101419";
      #  base01 = "#171B20";
      #  base02 = "#21262e";
      #  base03 = "#242931";
      #  base04 = "#485263";
      #  base05 = "#b6beca";
      #  base06 = "#dee1e6";
      #  base07 = "#e3e6eb";
      #  base08 = "#e5646a";
      #  base09 = "#f7b77c";
      #  base0A = "#f6d48f";
      #  base0B = "#94F7C5";
      #  base0C = "#79c3ee";
      #  base0D = "#75aaf0";
      #  base0E = "#cb8ff3";
      #  base0F = "#9d85e1";
      #};
    };
  };
}
