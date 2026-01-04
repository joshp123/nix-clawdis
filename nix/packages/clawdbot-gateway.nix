{ lib
, stdenv
, fetchFromGitHub
, nodejs_22
, pnpm_10
, pkg-config
, python3
, makeWrapper
, vips
, sourceInfo
, gatewaySrc ? null
, pnpmDepsHash ? null
}:

assert gatewaySrc == null || pnpmDepsHash != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "clawdbot-gateway";
  version = "2.0.0-beta4";

  src = if gatewaySrc != null then gatewaySrc else fetchFromGitHub sourceInfo;

  pnpmDeps = pnpm_10.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = if pnpmDepsHash != null
      then pnpmDepsHash
      else "sha256-oGXUm+oftkasXsK+QGlxe0xO7riWHdzpV0oK27lZrLw=";
    fetcherVersion = 2;
  };

  nativeBuildInputs = [
    nodejs_22
    pnpm_10
    pnpm_10.configHook
    pkg-config
    python3
    makeWrapper
  ];

  buildInputs = [ vips ];

  env = {
    SHARP_FORCE_GLOBAL_LIBVIPS = "1";
    npm_config_build_from_source = "true";
  };

  buildPhase = ''
    runHook preBuild
    pnpm install --offline --frozen-lockfile
    pnpm build
    pnpm ui:build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/clawdbot $out/bin

    cp -r dist node_modules package.json ui $out/lib/clawdbot/

    makeWrapper ${nodejs_22}/bin/node $out/bin/clawdbot \
      --add-flags "$out/lib/clawdbot/dist/index.js" \
      --set-default CLAWDBOT_NIX_MODE "1"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Telegram-first AI gateway (Clawdbot)";
    homepage = "https://github.com/clawdbot/clawdbot";
    license = licenses.mit;
    platforms = platforms.darwin ++ platforms.linux;
    mainProgram = "clawdbot";
  };
})
