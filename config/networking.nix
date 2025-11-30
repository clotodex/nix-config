{ lib, ... }:
{
  systemd.network.enable = true;

  # boot.initrd.systemd.network = {
  #   enable = true;
  #   networks = {inherit (systemd.network.networks) "10-lan1";};
  # };

  systemd.network.networks = {
    "10-lan1" = {
      DHCP = "yes";
      matchConfig.Name = "en*";
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        # MulticastDNS = true;
      };
      dhcpV4Config.RouteMetric = 10;
      dhcpV6Config.RouteMetric = 10;
    };
    "10-wlan1" = {
      DHCP = "yes";
      matchConfig.Name = "wl*";
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
        # MulticastDNS = true;
      };
      dhcpV4Config.RouteMetric = 40;
      dhcpV6Config.RouteMetric = 40;
    };
  };

  # networking.nftables.firewall = {
  #   zones.untrusted.interfaces = ["lan1" "wlan1"];
  # };

  networking = {
    # inherit (config.repo.secrets.local.networking) hostId;
    useDHCP = lib.mkForce false;
    useNetworkd = true;
    dhcpcd.enable = false;
    wireless.iwd.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        25565
        42671
      ];
      allowedUDPPortRanges = [
        # minecraft
        {
          from = 25565;
          to = 25565;
        }
        # quickshare
        {
          from = 42671;
          to = 42671;
        }
      ];
    };
    nftables.enable = true;
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
