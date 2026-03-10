_final: prev: {
  custom-scripts = {
    screenshot-area-scan-qr = prev.callPackage ./screenshot-area-scan-qr.nix { };
    niri-consume-stack = prev.callPackage ./niri-consume-stack.nix { };
  };
}
