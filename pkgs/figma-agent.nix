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
  src = inputs.figma-agent-src;
  nativeBuildInputs = with pkgs; [
    pkg-config
    rustPlatform.bindgenHook
    fontconfig
    freetype
  ];
  #buildInputs = with pkgs; [ dbus bluez ];
}
