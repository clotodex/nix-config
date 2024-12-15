{
  pkgs,
  config,
  ...
}:
{
  home = {
    packages = with pkgs; [
      gh
      gh-dash
      git-lfs
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
    ];
  };

  programs = {
    yazi = {
      enable = true;
      settings.manager = {
        show_hidden = true;
        show_symlink = true;
      };
    };

    bat = {
      enable = true;
      config.theme = "TwoDark";
    };
    fzf.enable = true;

    htop = {
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
        // (
          with config.lib.htop;
          leftMeters [
            (bar "LeftCPUs2")
            (bar "Memory")
            (bar "Swap")
            (bar "ZFSARC")
            (text "NetworkIO")
          ]
        )
        // (
          with config.lib.htop;
          rightMeters [
            (bar "RightCPUs2")
            (text "LoadAverage")
            (text "Tasks")
            (text "Uptime")
            (text "Systemd")
          ]
        );
    };
    gpg = {
      enable = true;
      scdaemonSettings.disable-ccid = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

}
