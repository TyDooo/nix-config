{
  virtualisation.oci-containers.containers.frigate = {
    image = "ghcr.io/blakeblackshear/frigate:0.13.1";
    autoStart = true;
    volumes = [
      "/mnt/cctv:/media/frigate"
      "/home/tygo/frigate:/config"
      "/etc/localtime:/etc/localtime:ro"
    ];
    ports = [
      "5001:5000"
      "8554:8554" # RTSP feeds
      "8555:8555/tcp" # WebRTC over tcp
      "8555:8555/udp" # WebRTC over udp
    ];
    extraOptions = [
      "--mount=type=tmpfs,target=/tmp/cache,tmpfs-size=1000000000"
      "--device=/dev/bus/usb:/dev/bus/usb"
      "--device=/dev/dri/renderD128"
      "--shm-size=64m"
    ];
  };
}
