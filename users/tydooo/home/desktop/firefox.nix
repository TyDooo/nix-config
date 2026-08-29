{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    profiles = {
      tydooo = {
        isDefault = true;

        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          sponsorblock
          ublock-origin
          violentmonkey

          kagi-search
          kagi-translate
        ];

        settings = {
          # 0 => blank page
          # 1 => your home page(s) {default}
          # 2 => the last page viewed in Firefox
          # 3 => previous session windows and tabs
          "browser.startup.page" = "3";

          "browser.startup.homepage" = "https://kagi.com";

          # Disable password manager
          "signon.rememberSignons" = "false";
          "signon.autofillForms" = "false";
          "signon.autofillForms.http" = "false";
        };
      };
    };
  };
}
