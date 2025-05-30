{
  buildNpmPackage,
  fetchFromGitHub,
  google-fonts,
  nodejs_20,
}: let
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "fosrl";
    repo = "pangolin";
    tag = "${version}";
    hash = "sha256-YCXL9UmsuY5qQUqRHbZEF5jrL24CKZMk/cVNW+DkAxI=";
  };
in
  buildNpmPackage {
    pname = "foslr-pangolin";
    inherit version src;

    nodejs = nodejs_20;

    npmDepsHash = "sha256-uN9CgzkDpHjapHsA6w7k+sETofLk4AKfMnXzb9xoXtY=";

    patches = [./patches/001-localfont.patch];

    # Overwrite the package-lock.json file as it doesn't provide all optional dependencies for the @node-rs/argon2 package.
    postPatch = ''
      cp ${./package-lock.json} ./package-lock.json
    '';

    preBuild = ''
      cp "${
        google-fonts.override {fonts = ["Inter"];}
      }/share/fonts/truetype/Inter[opsz,wght].ttf" src/app/Inter.ttf
    '';

    buildPhase = ''
      runHook preBuild

      # Generate drizzle schema files
      npx drizzle-kit generate --dialect sqlite --schema ./server/db/schemas/ --out init

      # Run the build command
      npm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      npm config delete cache
      npm prune --omit=dev

      mkdir -p $out/

      mv package.json package-lock.json node_modules $out/

      mv .next/standalone/.next $out/.next
      mv .next/static $out/.next/static
      mv dist $out/
      mv init $out/dist/init

      mv server/db/names.json $out/dist/names.json

      mv public $out/public

      mkdir -p $out/bin
      makeWrapper ${nodejs_20}/bin/node $out/bin/pangolin-migrate \
        --add-flags "$out/dist/migrations.mjs" \
        --set-default NODE_OPTIONS "--enable-source-maps" \
        --set-default NODE_ENV development \
        --set-default ENVIRONMENT prod \
        --prefix NODE_PATH : "$out/node_modules"
      makeWrapper ${nodejs_20}/bin/node $out/bin/pangolin \
        --add-flags "$out/dist/server.mjs" \
        --set-default NODE_OPTIONS "--enable-source-maps" \
        --set-default NODE_ENV development \
        --set-default ENVIRONMENT prod \
        --prefix NODE_PATH : "$out/node_modules"

      runHook postInstall
    '';
  }
