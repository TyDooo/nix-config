{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    # TODO: Set these to false in the future
    enableExtensionUpdateCheck = true;
    enableUpdateCheck = true;
    mutableExtensionsDir = true;
    extensions = with pkgs.vscode-extensions; [
      golang.go
      svelte.svelte-vscode
    ];
  };
}
