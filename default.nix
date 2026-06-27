{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  ttfautohint,
  copyPathToStore,
  families ? [
    "IosevkaCode"
    "IosevkaTerminal"
    "IosevkaWitchcraft"
    "IosevkaWitchcraftProportionalSans"
    "IosevkaWitchcraftProportionalSerif"
  ],
}:
buildNpmPackage {
  name = "iosevka-q60";

  nativeBuildInputs = [
    ttfautohint
  ];

  src = fetchFromGitHub {
    owner = "be5invis";
    repo = "iosevka";
    tag = "v34.6.3";
    sha256 = "sha256-fd1yi5tNNixedUMvoiJIpg4RF9omAJTAb2TD1B7bqV4=";
  };

  npmDepsHash = "sha256-n9fLY6z29PKn8ZJVCEXno8k+YE5X01BMesaRbsMGLcI=";

  buildPhase = let
    targets =
      families
      |> map (name: "ttf::${name}")
      |> lib.strings.concatStringsSep " ";
  in ''
    runHook preBuild
    ln -s ${copyPathToStore ./private-build-plans.toml} private-build-plans.toml
    npm run build -- ${targets} --jCmd=$NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = let
    install-fonts =
      families
      |> map (name: ''
        install "dist/${name}/TTF"/* "$fontdir"
      '')
      |> lib.strings.concatStrings;
  in ''
    runHook preInstall
    fontdir="$out/share/fonts/truetype"
    install -d "$fontdir"
    ${install-fonts}
    runHook postInstall
  '';
}
