{pkgs, ...}: {
  imports = [
    ./hyprland
  ];

  home.packages = with pkgs; [
    grimblast
    swaylock
    hyprpicker
    wl-clipboard
    waybar-custom-modules
    swww
    rofi-wayland
    libnotify
  ];

  services.hypridle = {
    enable = true;
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
