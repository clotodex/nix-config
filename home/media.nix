{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.mpris-proxy.enable = true;

  xdg.configFile."mpv/mpv.conf".text = ''
    hwdec=auto-safe
    vo=gpu
    profile=gpu-hq
    gpu-context=wayland
  '';
}
