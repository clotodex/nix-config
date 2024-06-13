{
  lib,
  ...
}: {
  systemd.network.enable = true;

  networking = {
    useDHCP = lib.mkForce false;
    useNetworkd = true;
    dhcpcd.enable = false;
  };

  services.resolved = {
    enable = true;
    dnssec = "false"; # wake me up in 20 years when DNSSEC is at least partly working
    fallbackDns = [
      "1.1.1.1"
      "2606:4700:4700::1111"
      "8.8.8.8"
      "2001:4860:4860::8844"
    ];
    llmnr = "false";
    # extraConfig = ''
    #   Domains=~.
    # ''; # MulticastDNS=true
  };
  }
