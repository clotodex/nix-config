{
  lib,
  pkgs,
  ...
}: {
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # TODO: install wild printers
}
