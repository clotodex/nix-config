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
    nativeBuildInputs = with pkgs; [ pkg-config dbus ];
    buildInputs = with pkgs; [ dbus udev ];
    cargoBuildOptions = x: x ++ [ "--workspace" "--exclude" "swaync-client" "--exclude" "swaync"];
  }
