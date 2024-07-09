inputs: [
  (import ./scripts)
  (_final: prev: {
    segoe-ui-ttf = prev.callPackage ./segoe-ui-ttf.nix {};
    project-chooser = prev.callPackage ./project-chooser.nix {};
    #earbuds = prev.callPackage ./earbuds.nix {};
    earbuds = prev.callPackage ../pkgs/earbuds.nix {inherit inputs;};
    waybar-custom-modules = prev.callPackage ../pkgs/waybar-modules.nix {inherit inputs;};
  })
]
