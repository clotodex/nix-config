












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
      bandwhich
      btop
      delta
      fd
      file
      hexyl
      killall
      ncdu
      neofetch
      nvd
      rage
      rclone
      ripgrep
      rnr
      rsync
      sd
      tree
      unzip
      zip
      wget
      usbutils
      pciutils
	  brightnessctl
	  telegram-desktop
    ];
  };

  programs = {
    bat = {
      enable = true;
      config.theme = "TwoDark";
    };
    fzf.enable = true;
    gpg.enable = true;
  };
  programs.htop = {
    enable = true;
    settings =
      {
        tree_view = 1;
        highlight_base_name = 1;
        show_cpu_frequency = 1;
        show_cpu_temperature = 1;
        show_program_path = 0;
        hide_kernel_threads = 1;
        hide_userland_threads = 1;
        sort_key = 46; # Sort by %CPU if not in tree mode
      }
      // (with config.lib.htop;
        leftMeters [
          (bar "LeftCPUs2")
          (bar "Memory")
          (bar "Swap")
          (bar "ZFSARC")
          (text "NetworkIO")
        ])
      // (with config.lib.htop;
        rightMeters [
          (bar "RightCPUs2")
          (text "LoadAverage")
          (text "Tasks")
          (text "Uptime")
          (text "Systemd")
        ]);
  };
}
