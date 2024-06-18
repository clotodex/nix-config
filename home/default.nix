{
  lib,
  nixosConfig,
  pkgs,
  ...
}: {
  imports =
    [
	  ./git.nix
	  ./ssh.nix
	  ./kitty.nix
	  ./swaync
	  ./theme
	  ./neovim
	  ./direnv.nix
	  ./packages.nix
	  # TODO: wait for nixvim
	  # ./manpager.nix

      # ./discord.nix
      # ./firefox.nix
      # ./kitty.nix
      # ./signal.nix
      # ./theme.nix
      # ./thunderbird.nix

      # # X11
      # ./i3.nix
      # ./flameshot.nix
      # ./wired-notify.nix

      # # Wayland
      # ./hyprland.nix
      # ./waybar.nix
      # ./rofi.nix
      # ./swaync.nix
      # ./swww.nix
    ];

  home = {
    packages = [
      pkgs.appimage-run
      pkgs.google-chrome
      pkgs.feh
      pkgs.pavucontrol
      pkgs.pinentry-gnome3 # For yubikey, gnome = gtk3 variant
      pkgs.xdg-utils
      pkgs.yt-dlp
      pkgs.zathura
	  pkgs.fd

	  pkgs.wl-clipboard

	  pkgs.discord
	  pkgs.webcord # INFO: hardened discord client

	  pkgs.project-chooser
    ];

# TODO: projects/external

    # TODO wrap thunderbird bin and set LC_ALL=de_DE.UTF-8 because thunderbird uses wrong date and time formatting with C.UTF-8
    # TODO make screenshot copy work even if notification fails (set -e does its thing here)
    # TODO pavucontrol shortcut or bar button
    # TODO keyboard stays lit on poweroff -> add systemd service to disable it on shutdown
    # TODO on neogit close do neotree update
    # TODO neovim gitsigns toggle_deleted keybind
    # TODO neovim gitsigns stage hunk shortcut
    # TODO neovim directtly opening file has different syntax
    # TODO neovim reopening file should continue at the previous position
    # TODO thunderbird doesn't use passwords from password command
    # TODO accounts.concats accounts.calendar
    # TODO mod+f1-4 for left monitor?
    # TODO sway shortcuts
    # TODO VP9 hardware video decoding blocklisted

  };

  xdg.mimeApps.enable = true;
}
