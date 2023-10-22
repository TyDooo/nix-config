{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.override {
      commandLineArgs = ''
        --enable-features=UseOzonePlatform \
        --ozone-platform=wayland
      '';
    };
    enableExtensionUpdateCheck = true;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions;
      [
        bbenoist.nix
        brettm12345.nixfmt-vscode

        usernamehw.errorlens

        # Copilot
        github.copilot

        # Theme
        catppuccin.catppuccin-vsc
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "catppuccin-perfect-icons";
        publisher = "thang-nm";
        version = "0.21.21";
        sha256 = "sha256-C4epmBAbxxr9z/ruJqv0GH8dk17vxq1xGlC0WDnYjnA=";
      }];
    userSettings = {
      "workbench.iconTheme" = "catppuccin-perfect-mocha";
      "workbench.colorTheme" = "Catppuccin Mocha";
      "window.titleBarStyle" = "custom";
      "window.nativeTabs" = true;
      "window.restoreWindows" = "all";
      "window.menuBarVisibility" = "toggle";
     };
  };
}
