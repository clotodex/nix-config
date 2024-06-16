{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "project-chooser";
  version = "master-ish";

  src = fetchFromGitHub {
    owner = "clotodex";
    repo = "project-chooser";
	rev = "1500851";
	hash = "sha256-OXreJfqaDIvTNRwcWOQTLEvJhs2RYgL0GsZbVqKk10k=";
  };

  cargoHash = "sha256-j12XkpsnA3K2c7MzllCHqGZZ+McAXb0wMZsPKOWLHRs=";

  meta = with lib; {
    description = "A way to index and quickly find and jump to projects";
    homepage = "https://github.com/clotodex/project-chooser";
    mainProgram = "project-chooser";
  };

  # TODO: build program module to also set up the zsh
}
