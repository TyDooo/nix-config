{
  flake.nixosModules.greetd = { inputs, ... }: {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
    ];

    programs.noctalia-greeter = {
      enable = true;
      greeter-args = "";
      settings = {
        user.default = "tydooo";
      };
    };
  };
}
