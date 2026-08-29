let
  browser = "firefox.desktop";
  image-viewer = "org.gnome.Loupe.desktop";
  video-player = "mpv.desktop";
in
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "application/xhtml+xml" = browser;
      "text/html" = browser;

      "application/pdf" = browser;

      "image/png" = image-viewer;
      "image/jpeg" = image-viewer;
      "image/gif" = image-viewer;
      "image/webp" = image-viewer;
      "image/tiff" = image-viewer;
      "image/bmp" = image-viewer;
      "image/x-canon-cr2" = "darktable.desktop";

      "video/mp2t" = video-player;
      "video/mp4" = video-player;
      "video/mpeg" = video-player;
      "video/ogg" = video-player;
      "video/webm" = video-player;
      "video/x-flv" = video-player;
      "video/x-matroska" = video-player;
      "video/x-msvideo" = video-player;

      "audio/aac" = video-player;
      "audio/mpeg" = video-player;
      "audio/ogg" = video-player;
      "audio/opus" = video-player;
      "audio/wav" = video-player;
      "audio/webm" = video-player;
      "audio/x-matroska" = video-player;
    };
  };
}
