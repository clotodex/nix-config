{
  rustPlatform,
  fetchFromGitHub,
}:
# TODO: switch to naersk + flake url style building
rustPlatform.buildRustPackage {
  pname = "project-chooser";
  version = "master-ish";
  useFetchCargoVendor = true;

  src = fetchFromGitHub {
    owner = "clotodex";
    repo = "project-chooser";
    rev = "1500851";
    hash = "sha256-OXreJfqaDIvTNRwcWOQTLEvJhs2RYgL0GsZbVqKk10k=";
  };

  cargoHash = "sha256-jxJq+1dgGhR4NQa73qQIUso07Nu8WeTTqbJVzTMZA+k=";

  meta = {
    description = "A way to index and quickly find and jump to projects";
    homepage = "https://github.com/clotodex/project-chooser";
    mainProgram = "project-chooser";
  };

  # TODO: build program module to also set up the zsh
}
