{
  pkgs,
  inputs,
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
let
  naersk' = pkgs.callPackage inputs.naersk { };
in
naersk'.buildPackage {
  src = inputs.project-chooser-src;
  #nativeBuildInputs = with pkgs; [ pkg-config dbus bluez libpulseaudio ];
  #buildInputs = with pkgs; [ dbus bluez ];
}
