{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;

    audio.enable = true;

    pulse.enable = true;
    jack.enable = true;
    alsa = {
      enable = true; # ALSA support
    };

    wireplumber.enable = true;
  };
}
