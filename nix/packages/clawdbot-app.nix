{ lib
, stdenvNoCC
, fetchzip
}:

stdenvNoCC.mkDerivation {
  pname = "clawdbot-app";
  version = "2026.1.16-2";

  src = fetchzip {
    url = "https://github.com/clawdbot/clawdbot/releases/download/v2026.1.16-2/Clawdbot-2026.1.16-2.zip";
    hash = "sha256-CQDGFA+/2McVxIw7WXtJZgr6LmtWTy0Dks++pjdU4rU=";
    stripRoot = false;
  };

  dontUnpack = true;

  installPhase = "${../scripts/clawdbot-app-install.sh}";

  meta = with lib; {
    description = "Clawdbot macOS app bundle";
    homepage = "https://github.com/clawdbot/clawdbot";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
