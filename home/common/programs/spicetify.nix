{
  pkgs,
  inputs,
  ...
}: {
  # themable spotify
  programs.spicetify = let
    spicePkgs =
      inputs.spicetify-nix.packages.${pkgs.hostPlatform.system}.default;
  in {
    enable = true;
    injectCss = true;
    replaceColors = true;
    overwriteAssets = true;
    sidebarConfig = true;
    enabledCustomApps = with spicePkgs.apps; [
      reddit
      lyrics-plus
      new-releases
    ];
    theme = spicePkgs.themes.catppuccin-mocha;
    colorScheme = "pink";
    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      hidePodcasts
      shuffle
      skipStats
      autoVolume
      autoSkip
      savePlaylists
      phraseToPlaylist
      wikify
      autoSkip
      copyToClipboard
      history
      groupSession
      loopyLoop
      trashbin
      bookmark
      keyboardShortcut
      fullAppDisplayMod
    ];
  };
}
