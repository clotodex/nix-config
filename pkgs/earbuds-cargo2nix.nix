{
  pkgs,
  inputs,
  lib,
  rustPlatform,
  fetchFromGitHub,
}: let
  # create the workspace & dependencies package set
  rustPkgs =
    pkgs.rustBuilder.makePackageSet
    {
      # rust toolchain version
      rustVersion = "1.75.0";
      # nixified Cargo.lock
      packageFun = import ./earbuds-cargo.nix;
      ignoreLockHash = true;

      # Provide the gperfools lib for linking the final rust-analyzer binary
      #packageOverrides = pkgs:
      #  pkgs.rustBuilder.overrides.all
      #  ++ [
      #    (pkgs.rustBuilder.rustLib.makeOverride {
      #      name = "earbuds";
      #      overrideAttrs = drv: {
      #        propagatedNativeBuildInputs =
      #          drv.propagatedNativeBuildInputs
      #          or []
      #          ++ [
      #            pkgs.gperftools
      #          ];
      #      };
      #    })
      #  ];

      preBuild = "sed s/pulse::libpulse.so.0/pulse/ -i target/*link*";

      # Use the existing all list of overrides and append your override
    #packageOverrides = pkgs: pkgs.rustBuilder.overrides.all ++ [
    #
    #  # parentheses disambiguate each makeOverride call as a single list element
    #  (pkgs.rustBuilder.rustLib.makeOverride {
    #      name = "fantasy-zlib-sys";
    #      overrideAttrs = drv: {
    #        propagatedBuildInputs = drv.propagatedBuildInputs or [ ] ++ [
    #          pkgs.pulse.dev
    #        ];
    #      };
    #  })
    #];

      workspaceSrc = inputs.earbuds-src;
      # You can also use local paths for local development with a checked out copy
      # workspaceSrc = ../../../upstream/rust-analyzer;
    };
in (rustPkgs.workspace.earbuds {})
#.workspace
#.earbuds
#rustPlatform.buildRustPackage rec {
#  pname = "earbuds";
#  version = "master-ish";
#  src = fetchFromGitHub {
#    owner = "JojiiOfficial";
#    repo = "LiveBudsCli";
#    rev = "df46706";
#    hash = "sha256-IEor7aZnwCA6Rg2gXIYSQ65hV/jJOKehujOSZnVzVis=";
#  };
#  cargoHash = "";
#  cargoLock = {
#    outputHashes = {
#      "galaxy-buds-rs" = "";
#    };
#  };
#  meta = {
#    description = "Control galaxy buds from the command line";
#    homepage = "https://github.com/JojiiOfficial/LiveBudsCli";
#    mainProgram = "earbuds";
#  };
#}
# rustPlatform.buildRustPackage rec {
#   pname = "project-chooser";
#   version = "master-ish";
#
#   src = fetchFromGitHub {
#     owner = "JojiiOfficial";
#     repo = "LiveBudsCli";
#     rev = "df46706";
#     hash = "sha256-IEor7aZnwCA6Rg2gXIYSQ65hV/jJOKehujOSZnVzVis=";
#   };
#
#   cargoHash = "";
#
#   cargoLock = {
#     outputHashes = {
#       "galaxy-buds-rs" = "";
#     };
#   };
#
#   meta = {
#     description = "Control galaxy buds from the command line";
#     homepage = "https://github.com/JojiiOfficial/LiveBudsCli";
#     mainProgram = "earbuds";
#   };
#
# }

