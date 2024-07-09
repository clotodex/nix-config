{
  lib,
  pkgs,
  ...
}: {
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    extraConf = ''
      DefaultEncryption Never
    '';
    drivers = with pkgs; [ gutenprint hplip splix brlaser ];
  };
  # TODO: install wild printers
}
