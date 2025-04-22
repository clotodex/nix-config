{
  config,
  lib,
  pkgs,
  minimal,
  ...
}:
let
  myuser = "clotodex";
in
{
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  #i18n.defaultLocale = "C.UTF-8";
  console = {
    #   font = "Lat2-Terminus16";
    keyMap = "de-latin1-nodeadkeys";
    font = "ter-v28n";
    packages = [ pkgs.terminus_font ];
    #   useXkbConfig = true; # use xkb.options in tty.
  };

  # users.groups.${myuser}.gid = config.users.users.${myuser}.uid;
  users.users.${myuser} = {
    uid = 1000;
    initialPassword = "password";
    createHome = true;
    # group = myuser;
    group = "users";
    extraGroups = [
      "wheel"
      "input"
      "sudo"
      "sound"
      "video"
    ];
    isNormalUser = true;
    autoSubUidGidRange = false;
    shell = pkgs.zsh;
  };

  # Required even when using home-manager's zsh module since the /etc/profile load order
  # is partly controlled by this. See nix-community/home-manager#3681.
  # FIXME: remove once we have nushell
  programs.zsh = {
    enable = true;
    # Disable the completion in the global module because it would call compinit
    # but the home manager config also calls compinit. This causes the cache to be invalidated
    # because the fpath changes in-between, causing constant re-evaluation and thus startup
    # times of 1-2 seconds. Disable the completion here and only keep the home-manager one to fix it.
    enableCompletion = false;
    # Autostart hyprland if on tty1 (once, don't restart after logout)
  };

  # TODO: Autologin
  # services.getty.autologinUser = myuser;

  home-manager.users.${myuser} = {
    imports = [
      ../home.nix
      ../shell/default.nix
      ../home
      # ../config
      # ./dev
      # ./graphical
      # ./neovim

      # ./git.nix
      # ./gpg.nix
      # ./ssh.nix
    ];

    programs.zsh.initExtra = lib.mkOrder 9999 ''
      if [[ -t 0 && "$(tty || true)" == /dev/tty1 && -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]] && uwsm check may-start; then
        echo "Login shell detected. Starting Hyprland..."
        uwsm start -S -F Hyprland
      fi
    '';

    # home = {
    #   inherit (config.users.users.${myuser}) uid;
    #   username = config.users.users.${myuser}.name;
    # };
  };
}
