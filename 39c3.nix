# set this as networkmanager.ensureProfiles.profiles."39C3"
{
  connection.id = "39C3";
  connection.type = "wifi";
  wifi.mode = "infrastructure";
  wifi.ssid = "39C3";
  wifi-security.auth-alg = "open";
  wifi-security.key-mgmt = "wpa-eap";
  "802-1x" = {
    anonymous-identity = "39C3";
    eap = "ttls;";
    identity = "39C3";
    password = "39C3";
    phase2-auth = "pap";
    altsubject-matches = "DNS:radius.c3noc.net";
    ca-cert = "${builtins.fetchurl {
      url = "https://letsencrypt.org/certs/isrgrootx1.pem";
      sha256 = "sha256:1la36n2f31j9s03v847ig6ny9lr875q3g7smnq33dcsmf2i5gd92";
    }}";
  };
  ipv4.method = "auto";
  ipv6.addr-gen-mode = "default";
  ipv6.method = "auto";
}
