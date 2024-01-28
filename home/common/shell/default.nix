{pkgs, ...}: {
  imports = [
    ./bash.nix
    ./direnv.nix
    ./git.nix
    ./starship.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    ripgrep # Better grep
    fd # Better find

    nil # Nix LSP
    p7zip

    vim
    gnumake
    neofetch
  ];

  programs = {
    eza.enable = true;
    btop.enable = true;

    dircolors = {
      enable = true;
      enableZshIntegration = true;
    };

    skim = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --hidden";
      changeDirWidgetOptions = [
        "--preview 'eza --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };
  };
}
