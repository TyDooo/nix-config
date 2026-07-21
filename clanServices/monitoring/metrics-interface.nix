{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types)
    attrsOf
    enum
    listOf
    str
    submodule
    ;
in
{
  options.endpoints = mkOption {
    type = listOf (submodule {
      options = {
        name = mkOption {
          type = str;
          description = "Prometheus job name for the metrics endpoint.";
        };

        address = mkOption {
          type = str;
          example = "127.0.0.1:4000";
          description = "Host and port Alloy should scrape.";
        };

        scheme = mkOption {
          type = enum [
            "http"
            "https"
          ];
          default = "http";
          description = "HTTP scheme used to scrape the endpoint.";
        };

        path = mkOption {
          type = str;
          default = "/metrics";
          description = "HTTP path serving Prometheus metrics.";
        };

        labels = mkOption {
          type = attrsOf str;
          default = { };
          description = "Additional labels attached to metrics from this endpoint.";
        };
      };
    });
    default = [ ];
    description = "Prometheus endpoints exported by services on a machine.";
  };
}
