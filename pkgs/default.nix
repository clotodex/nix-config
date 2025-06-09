{ inputs, pkgs }:
[
  (import ./scripts)
  (_final: prev: {
    segoe-ui-ttf = prev.callPackage ./segoe-ui-ttf.nix { };
    project-chooser = prev.callPackage ./project-chooser-naersk.nix { inherit inputs; };
    #earbuds = prev.callPackage ./earbuds.nix {};
    earbuds = prev.callPackage ../pkgs/earbuds.nix { inherit inputs; };
    figma-agent-build = prev.callPackage ../pkgs/figma-agent.nix { inherit inputs; };
    waybar-custom-modules = prev.callPackage ../pkgs/waybar-modules.nix { inherit inputs; };

    hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  })
]
