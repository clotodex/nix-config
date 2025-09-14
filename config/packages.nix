{
  lib,
  pkgs,
  ...
}: {
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  #services.flatpak.enable = true;
  services.pcscd.enable = true;


  #services.clamav = {
  #  daemon.enable = true;
  #  updater.enable = true;
  #};
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    kitty
    borgbackup
    tree
    fzf
    ripgrep
    acpi
    git
    killall
    bc
    wlr-randr
    dua
    duf
    colordiff
    diffutils
    difftastic
    rustc
    cargo
    kitty.terminfo
  ];
}
