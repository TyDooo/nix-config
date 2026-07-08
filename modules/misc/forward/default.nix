# Extends the VPN-Confinement module (https://github.com/Maroka-chan/VPN-Confinement)
# with NAT-PMP port forwarding support. Periodically renews port mappings via natpmpc
# and optionally updates qBittorrent's listening port through its WebUI API.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mapAttrs'
    nameValuePair
    optional
    optionalString
    ;
  inherit (lib.types)
    attrsOf
    submodule
    bool
    port
    ;
in
{
  options.vpnNamespaces = mkOption {
    type = attrsOf (
      submodule (_: {
        options.forward = {
          enable = mkOption {
            type = bool;
            default = false;
            description = "Whether to enable NAT-PMP port forwarding on this VPN namespace.";
          };

          gateway = mkOption {
            type = lib.types.str;
            default = "10.2.0.1";
            description = "NAT-PMP gateway address.";
          };

          qbittorrent = {
            enable = mkOption {
              type = bool;
              default = false;
              description = "Whether to update the forwarded port in qBittorrent.";
            };

            port = mkOption {
              type = port;
              default = config.services.qbittorrent.webuiPort;
              description = "The port qBittorrent WebUI is reachable on within the VPN namespace.";
            };
          };
        };
      })
    );
  };

  config =
    let
      enabledNamespaces = lib.pipe config.vpnNamespaces [
        (lib.mapAttrs (_: vpnNamespaceConfig: vpnNamespaceConfig.forward))
        (lib.filterAttrs (_: forwardConfig: forwardConfig.enable))
      ];
    in
    mkIf (config.vpnNamespaces != { }) {
      # Based on https://github.com/ImUrX/nixfiles/blob/b07d94b2a7dec5c5d8c93d60b706434db3514554/modules/wg-pnp.nix

      systemd.timers = mapAttrs' (
        vpnNamespace: forwardConfig:
        nameValuePair "${vpnNamespace}-port-forwarding" {
          wantedBy = [ "timers.target" ];
          after = [
            "${vpnNamespace}.service"
          ]
          ++ optional forwardConfig.qbittorrent.enable "qbittorrent.service";
          timerConfig = {
            # Run every 45s to ensure the port doesn't expire
            OnBootSec = "45s";
            OnUnitActiveSec = "45s";
            Unit = "${vpnNamespace}-port-forwarding.service";
          };
        }
      ) enabledNamespaces;

      systemd.services = mapAttrs' (
        vpnNamespace: forwardConfig:
        nameValuePair "${vpnNamespace}-port-forwarding" {
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
          bindsTo = [ "${vpnNamespace}.service" ];
          after = [
            "${vpnNamespace}.service"
          ]
          ++ optional forwardConfig.qbittorrent.enable "qbittorrent.service";

          vpnConfinement = {
            enable = true;
            vpnNamespace = "${vpnNamespace}";
          };

          path = with pkgs; [
            wget
            libnatpmp
            ripgrep
            iptables
          ];

          script = ''
            # bash
            set -euo pipefail

            port_file="/tmp/${vpnNamespace}-port"
            old_port="$(cat "$port_file" 2>/dev/null || echo "")"

            # Renew the NAT-PMP mapping for both protocols. We assume that the TCP and UDP ports are the same.
            result="$(natpmpc -a 1 0 udp 60 -g ${forwardConfig.gateway})"
            result="$(natpmpc -a 1 0 tcp 60 -g ${forwardConfig.gateway})"
            echo "$result"

            new_port="$(echo "$result" | rg --only-matching --replace '$1' 'Mapped public port (\d+) protocol')"
            echo "$new_port" > "$port_file"

            ${optionalString forwardConfig.qbittorrent.enable ''
              echo "Updating qBittorrent listen port to $new_port..."
              wget -O- -nv --retry-connrefused \
                --post-data "json={\"listen_port\":$new_port,\"current_network_interface\":\"${vpnNamespace}0\",\"random_port\":false,\"upnp\":false}" \
                http://127.0.0.1:${toString forwardConfig.qbittorrent.port}/api/v2/app/setPreferences
              echo ""
            ''}

            if [ "$new_port" = "$old_port" ]; then
              echo "Port unchanged ($new_port), nothing to do."
              exit 0
            fi
            echo "Mapped port $new_port, old was ''${old_port:-none}."

            # Open new port in iptables
            for protocol in udp tcp; do
              if iptables -C INPUT -p "$protocol" --dport "$new_port" -j ACCEPT -i ${vpnNamespace}0 2>/dev/null; then
                echo "Port $new_port/$protocol already open."
              else
                echo "Opening port $new_port/$protocol."
                iptables -I INPUT -p "$protocol" --dport "$new_port" -j ACCEPT -i ${vpnNamespace}0
              fi
            done

            # Close old port if it changed
            if [ -n "$old_port" ]; then
              for proto in udp tcp; do
                if iptables -C INPUT -p "$proto" --dport "$old_port" -j ACCEPT -i ${vpnNamespace}0 2>/dev/null; then
                  echo "Closing old port $old_port/$proto."
                  iptables -D INPUT -p "$proto" --dport "$old_port" -j ACCEPT -i ${vpnNamespace}0
                fi
              done
            fi
          '';
        }
      ) enabledNamespaces;

      # TODO: set qbittorrent port to 0 if the VPN interface goes down
      # TODO: set qbittorrent port after qbittorrent restart
    };
}
