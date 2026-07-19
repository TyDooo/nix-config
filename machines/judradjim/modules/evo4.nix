{
  services.pipewire.wireplumber.extraConfig = {
    "9-audient-evo4" = {
      "monitor.alsa.rules" = [
        {
          # Unused: disable
          matches = [
            { "node.description" = "~EVO4 Loopback.*"; }
            { "node.description" = "EVO4 Mic 2 / Line 2"; }
          ];
          actions.update-props = {
            "node.disabled" = true;
          };
        }
      ];
    };
  };
}
