{
  virtualisation.oci-containers.containers.homarr = {
    autoStart = true;
    image = "ghcr.io/ajnart/homarr:0.14.2";
    ports = [ "7575:7575" ];
    volumes = [
      "/opt/homarr/configs:/app/data/configs"
      "/opt/homarr/icons:/app/public/icons"
      "/opt/homarr/data:/data"
    ];
  };
}
