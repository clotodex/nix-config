












{ inputs, config, pkgs, ... }:
{

	# home.username="clotodex";
	# home.homeDirectory="/home/clotodex/";
	# 	# ...
	# 	plugins = [
	# 		inputs.Hyprspace.packages.${pkgs.system}.Hyprspace
	# 	# ...
	# 	];
	# };

	programs.home-manager.enable = true;

	 home = {
    packages = with pkgs; [
    ];
  };
}
