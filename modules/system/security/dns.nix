{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nixtra.security.vpn;
in
{
  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.type == "mullvad") {
      # Prevent NetworkingManager from fetching DNS settings
      # via DHCP (i.e., getting the router's preferred DNS
      # configurations).
      #
      # Even if the user is not using a VPN, the preconfigured
      # DNS servers are better in terms of privacy than the
      # ISP-issues ones most of the time.
      # system.activationScripts."disable-fetch-router-dns".text = ''
      #   export PATH=${pkgs.networkmanager}/bin:${pkgs.systemd}/bin:$PATH
      #   set -euo pipefail

      #   if [[ "$(systemctl is-system-running)" != "running" ]]; then
      #     exit 0
      #   fi

      #   echo "Updating NetworkManager connections..."

      #   mapfile -t connections < <(nmcli -t -f NAME connection show)

      #   exceptions=(${
      #     lib.concatStringsSep " "
      #     config.nixtra.security.nmConnectionRouterDnsExceptions
      #   })

      #   for conn in "''${connections[@]}"; do
      #     if [[ " ''${connections[@]} " =~ " ''${conn} " ]]; then
      #       continue
      #     fi

      #     ipv4_setting=$(nmcli -g ipv4.ignore-auto-dns connection show "$conn")
      #     ipv6_setting=$(nmcli -g ipv6.ignore-auto-dns connection show "$conn")

      #     if [[ "$ipv4_setting" == "yes" && "$ipv6_setting" == "yes" ]]; then
      #       continue
      #     fi

      #     nmcli connection modify "$conn" ipv4.ignore-auto-dns yes
      #     nmcli connection modify "$conn" ipv6.ignore-auto-dns yes

      #     nmcli connection down "$conn" || true  # Don't fail if already disconnected
      #     nmcli connection up "$conn"
      #   done

      #   echo "All connections have been updated"
      # '';

      systemd.user.services."dns-leak-test" =
        let
          after = [ "graphical.target" ];
          enable = true;

          fetchDnsScript = pkgs.writeText "fetch-dns.py" ''
            #!/usr/bin/env python3

            # dnsleaktest v0.7 python CLI Created by Tugzrida(https://gist.github.com/Tugzrida)
            from __future__ import print_function

            version = "0.7"

            import sys, socket, getopt, os.path
            from uuid import uuid4
            from json import loads, dumps
            try:
                from urllib.request import urlopen, Request
                from urllib.error import HTTPError, URLError
            except ImportError:
                from urllib2 import urlopen, Request, HTTPError, URLError

            def formatIPorName(address):
                # Accepts an ip address or hostname, returns a formatted output (where the
                # resolved part is in parentheses), and the ip address
                try:
                    ip = socket.getaddrinfo(address, None)[0][4][0]
                except (socket.herror, socket.gaierror):
                    sys.exit("DNS server address is invalid or does not resolve!")

                if ip == address:
                    try:
                        return "{} ({})".format(address, socket.gethostbyaddr(address)[0]), address
                    except (socket.herror, socket.gaierror):
                        return "{} (No PTR)".format(address), address
                else:
                    return "{} ({})".format(address, ip), ip

            def dns_req(uuid, server, port):
                # Accepts a 36-character uuid, DNS server and port through which to lookup {uuid}.test.dnsleaktest.com

                req = b'\x42\x42\x01\x10\x00\x01\x00\x00\x00\x00\x00\x00\x24' + uuid.encode("utf-8") + b'\x04test\x0bdnsleaktest\x03com\x00\x00\x01\x00\x01'

                try:
                    try:
                        skt = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                        skt.sendto(req, (server, port))
                    except socket.gaierror:
                        skt = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
                        skt.sendto(req, (server, port))
                    skt.settimeout(5)
                    skt.recv(512)
                except (socket.timeout, socket.error) as e:
                    sys.exit("Error connecting to DNS server: " + str(e))


            testIDs = []

            server = None
            extended = False
            port = 53
            json = False

            # Handle opts
            try:
                opts, args = getopt.getopt(sys.argv[1:],"ejs:p:")
            except getopt.GetoptError:
                sys.exit(''''Usage: {} [-e] [-j] [-s server] [-p port]
                -e:         extended test, 36 lookups rather than the default 6
                -j:         json output
                -s server:  trace lookups through a specific DNS server, rather than the system defaults.
                            In this mode, the behaviour is less like a leak test and more like a tracer.
                -p port:    specify a non-standard port for the DNS server
            v{} Created by Tugzrida(https://gist.github.com/Tugzrida)''''.format(os.path.basename(__file__), version))
            for opt, arg in opts:
                if opt == "-j": json = True
                if opt == "-e": extended = True
                if opt == "-s":
                    if arg:
                        formattedServer, server = formatIPorName(arg)
                    else:
                        sys.exit("DNS server address not provided!")
                if opt == "-p":
                    if not any(i[0] == "-s" for i in opts): sys.exit("Must specify a server for port number to work!")
                    try:
                        if 0 <= int(arg) <= 65535:
                            port = int(arg)
                        else:
                            sys.exit("DNS server port number must be in the range 0-65535!")
                    except ValueError:
                        sys.exit("DNS server port number must be an integer!")

            # Begin the tests
            #if not json: print("Starting {}DNS leak test via {}{}...".format("extended " if extended else "", formattedServer if server else "system resolver", " port " + str(port) if port != 53 else ""))

            for _ in range(36 if extended else 6):
                testIDs.append(str(uuid4()))

            try:
                urlopen(Request("https://www.dnsleaktest.com/api/v1/identifiers", headers={"User-Agent": "dnsleaktestcli/{} (https://gist.github.com/Tugzrida)".format(version), "Content-Type": "application/json;charset=UTF-8"}), dumps({"identifiers": testIDs}).encode("utf-8"), timeout=5)
            except HTTPError:
                pass # Endpoint always returns 400 Bad Request
            except URLError:
                sys.exit("Unable to reach dnsleaktest.com!")

            for testCount in range(36 if extended else 6):
                if server:
                    dns_req(testIDs[testCount], server, port)
                else:
                    socket.gethostbyname("{}.test.dnsleaktest.com".format(testIDs[testCount]))
                #if not json: print("\rTest {}/{}".format(testCount+1, 36 if extended else 6), end="")
                sys.stdout.flush()

            # Get the results
            res = loads(urlopen(Request("https://www.dnsleaktest.com/api/v1/servers-for-result", headers={"User-Agent": "dnsleaktestcli/{} (https://gist.github.com/Tugzrida)".format(version), "Content-Type": "application/json;charset=UTF-8"}), dumps({"queries": testIDs}).encode("utf-8"), timeout=5).read().decode("utf-8"))

            if json:
                print(dumps(res))
            else:
                #print("\rDiscovered DNS recursors are:")
                max_ip_len = max(len(x["ip_address"]) for x in res)
                if max_ip_len == 0: sys.exit('  No recursors found!')
                for server in res:
                    if server["hostname"] == "None": server["hostname"] = "No PTR"
                    print("{srv[ip_address]:>{pad}}".format(srv=server, pad=max_ip_len))


          '';
        in
        lib.mkIf (cfg.dnsLeakPrevention.dnsLeakTest) {
          enable = true;
          after = [ "graphical.target" ];
          path = with pkgs; [
            python3
            whois
          ];
          script = ''
            IPS=()

            while [ ''${#IPS[@]} -eq 0 ]; do
              IPS_RAW=$(python3 ${fetchDnsScript} -e)
              readarray -t IPS <<< "$IPS_RAW"
              if [ ''${#IPS[@]} -eq 0 ]; then
                echo "No DNS servers found. Retrying in 60s..."
                sleep 60
              fi
            done

            for IP in "''${IPS[@]}"; do
              echo "Checking IP: $IP"
              
              WHOIS_DATA=""
              until WHOIS_DATA=$(whois "$IP" 2>/dev/null) && [ -n "$WHOIS_DATA" ]; do
                echo "whois failed or empty. Retrying in 30s..."
                sleep 30
              done

              if echo "$WHOIS_DATA" | grep -Ei 'Mullvad|AS39351|AS216025' >/dev/null; then
                echo "WHOIS: IP appears to be associated with Mullvad"
              else
                echo "WHOIS: No Mullvad identifiers found"
                ${pkgs.libnotify}/bin/notify-send -u critical "DNS Leak Detected" "Nixtra has detected a potential DNS Leak with your VPN configuration. Networking has been disabled."
                ${pkgs.networkmanager}/bin/nmcli networking off
              fi
            done
          '';

          serviceConfig = {
            Type = "oneshot";
          };
        };
    })
  ];
}
