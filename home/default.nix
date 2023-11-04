{ nur, inputs, outputs, ... }:

{
  imports = [
    inputs.spicetify-nix.homeManagerModule

    ./desktop
    ./programs
    ./shell
  ] ++ (builtins.attrValues outputs.homeManagerModules);

  home = {
    username = "tygo";
    homeDirectory = "/home/tygo";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.05";
  };

  # home-manager nixpkgs config
  nixpkgs.overlays = [ nur.overlay ];

  # TODO: Move to host specific file
  monitors = [{
    name = "DP-1";
    width = 3440;
    height = 1440;
    refreshRate = 120;
    primary = true;
  }];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
