{pkgs, ...}: {
  imports = [
    ./hyprland
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    (grimblast.override { hyprland = null; })
    swaylock
    hyprpicker
    wl-clipboard
    swww
    rofi-wayland
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
}
