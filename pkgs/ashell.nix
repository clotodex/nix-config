{
  pkgs,
  inputs,
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
let
  naersk' = pkgs.callPackage inputs.naersk { };

  buildInputs = with pkgs; [
    rustPlatform.bindgenHook
    pkg-config
    libxkbcommon
    libGL
    pipewire
    libpulseaudio
    wayland
    vulkan-loader
    udev
  ];

  runtimeDependencies = with pkgs; [
    libpulseaudio
    wayland
    mesa
    vulkan-loader
    libGL
    libglvnd
  ];

  ldLibraryPath = pkgs.lib.makeLibraryPath runtimeDependencies;
in
naersk'.buildPackage {
  src = inputs.ashell-src;
  nativeBuildInputs = with pkgs; [
    dbus
    bluez
    libpulseaudio
    rustPlatform.bindgenHook

    makeWrapper
    pkg-config
    autoPatchelfHook # Add runtimeDependencies to rpath
  ];
  inherit buildInputs runtimeDependencies ldLibraryPath;

  postInstall = ''
    wrapProgram "$out/bin/ashell" --prefix LD_LIBRARY_PATH : "${ldLibraryPath}"
  '';
}
