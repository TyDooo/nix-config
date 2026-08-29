{
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat";
      tree = "${pkgs.eza}/bin/eza -T";
    }
    //
      lib.mkIf
        (builtins.elem "graphical"
          osConfig.clanConfig.inventory.machines.${osConfig.clan.core.settings.machine.name}.tags
        )
        {
          ssh = "kitten ssh";
        };
  };
}
