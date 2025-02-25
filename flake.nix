{
  description = "custom Iosevka build";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  nixConfig = {
    extra-substituters = [
      "https://kira.cachix.org/"
    ];

    extra-trusted-public-keys = [
      "kira.cachix.org-1:THBrq/BplPxOJnWnxCBMOeP03ReON+FUYZpiDTnZqwA="
    ];
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem
    (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) buildNpmPackage;
    in {
      packages = {
        default = buildNpmPackage {
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
        };
      };

      apps.default = utils.lib.mkApp {drv = self.packages.${system}.default;};
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [nodejs_23 ttfautohint];
      };
    });
}
