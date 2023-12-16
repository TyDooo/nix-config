{pkgs, ...}: {
  # Needed for firefox and thunderbird
  home.packages = [pkgs.libnotify];

  services.mako = {
    enable = true;
    anchor = "top-right";
    backgroundColor = "#1e1e2e";
    textColor = "#cdd6f4";
    borderColor = "#89b4fa";
    progressColor = "over #313244";
    extraConfig = ''
      [urgency=high]
      border-color=#fab387
    '';
  };
}
