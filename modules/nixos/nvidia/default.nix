{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.tydooo.nvidia;
in {
  options.tydooo.nvidia = {
    enable = mkEnableOption "nvidia drivers";
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = ["nvidia"];

    environment.variables = {
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    environment.systemPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
    ];

    hardware = {
      nvidia = {
        open = true;
        modesetting.enable = true;
        powerManagement.enable = true; # Disable if issues with sleep/suspend
      };
      opengl = {
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
          vaapiVdpau
          libvdpau-va-gl
        ];
      };
    };
  };
}
