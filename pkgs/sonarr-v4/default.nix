{
  lib,
  stdenv,
  fetchurl,
  sqlite,
  curl,
  makeWrapper,
  icu,
  dotnet-runtime,
  openssl,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "sonarr-v4";
  version = "4.0.0.738";

  src = fetchurl {
    url = "https://download.sonarr.tv/v4/develop/${version}/Sonarr.develop.${version}.linux-x64.tar.gz";
    hash = "sha256-NulMWWB1FWKLaUjSrr+f1wvtC7174oLwEOyFuqCqWZ0=";
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/${pname}-${version}}
    cp -r * $out/share/${pname}-${version}/.

    makeWrapper "${dotnet-runtime}/bin/dotnet" $out/bin/NzbDrone \
      --add-flags "$out/share/${pname}-${version}/Sonarr.dll" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
      curl
      sqlite
      openssl
      icu
      zlib
    ]}

    runHook postInstall
  '';

  meta = {
    description = "Smart PVR for newsgroup and bittorrent users";
    homepage = "https://sonarr.tv/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [TyDooo];
    mainProgram = "NzbDrone";
    platforms = lib.platforms.all;
  };
}
