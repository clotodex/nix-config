{pkgs, ...}: {
  imports = [
    ./hyprland
  ];

  home.packages = with pkgs; [
    hypridle
    grimblast
    swaylock
    hyprpicker
    wl-clipboard
    waybar-custom-modules
    swww
    rofi-wayland
  ];
}
