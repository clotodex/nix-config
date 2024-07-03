












{ inputs, config, pkgs, ... }:
{

	# home.username="clotodex";
	# home.homeDirectory="/home/clotodex/";
	home.stateVersion = "24.05";
	# TODO:  wayland.windowManager.hyprland = {
	# 	enable = true;
    # xwayland.enable = true;
    # systemd.enable = true;
	# systemd.variables = ["--all"];

	# 	# ...
	# 	plugins = [
	# 		inputs.Hyprspace.packages.${pkgs.system}.Hyprspace
	# 	# ...
	# 	];
	# };

	programs.home-manager.enable = true;

	 home = {
    packages = with pkgs; [
	  firefox
	  brightnessctl
	  telegram-desktop
	  signal-desktop
	  dunst
	  google-chrome
    ];
  };
}
