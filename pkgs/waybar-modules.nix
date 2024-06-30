{
  pkgs,
  inputs,
  lib,
  rustPlatform,
  fetchFromGitHub,
}: let
  naersk' = pkgs.callPackage inputs.naersk {};
in
  naersk'.buildPackage {
    src = inputs.waybar-custom-modules-src;
    nativeBuildInputs = with pkgs; [pkg-config dbus];
    buildInputs = with pkgs; [dbus udev];
    cargoBuildOptions = x: x ++ [
      "--workspace"
      "--exclude" "swaync-client"
      "--exclude" "swaync"
      "--exclude" "webcam"
      ];
    postInstall = ''
      mv $out/bin/cpu $out/bin/waybar-cpu
      mv $out/bin/mem $out/bin/waybar-mem
      mv $out/bin/cpufreq $out/bin/waybar-cpurfeq
    '';
  }
