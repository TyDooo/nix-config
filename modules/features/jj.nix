{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.jj-wrapped = inputs.wrapper-modules.wrappers.jujutsu.wrap {
      inherit pkgs;

      settings = {
        user.name = "TyDooo";
        user.email = "hi" + "@" + "tydooo." + "dev";
      };
    };
  };
}
