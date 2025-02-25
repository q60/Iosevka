{pkgs ? import <nixpkgs> {}}:
pkgs.buildNpmPackage {
  name = "iosevka-q60";

  nativeBuildInputs = with pkgs; [
    ttfautohint
  ];

  src = ./.;

  npmDepsHash = "sha256-TOFCTYReO7eNBv1udG1Ie3Zww3uOVPFTo0x0jwyCAHE=";

  buildPhase = ''
    runHook preBuild
    npm run build -- ttf::IosevkaCode --jCmd=6
    npm run build -- ttf::IosevkaTerminal --jCmd=6
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    fontdir="$out/share/fonts/truetype"
    install -d "$fontdir"
    install "dist/IosevkaCode/TTF"/* "$fontdir"
    install "dist/IosevkaTerminal/TTF"/* "$fontdir"
    runHook postInstall
  '';
}
