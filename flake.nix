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

          src = pkgs.fetchFromGitHub {
            owner = "be5invis";
            repo = "iosevka";
            tag = "v34.6.3";
            sha256 = "sha256-fd1yi5tNNixedUMvoiJIpg4RF9omAJTAb2TD1B7bqV4=";
          };

          npmDepsHash = "sha256-n9fLY6z29PKn8ZJVCEXno8k+YE5X01BMesaRbsMGLcI=";

          buildPhase = ''
            runHook preBuild
            ln -s ${pkgs.copyPathToStore ./private-build-plans.toml} private-build-plans.toml
            npm run build -- ttf::IosevkaCode --jCmd=$NIX_BUILD_CORES
            npm run build -- ttf::IosevkaTerminal --jCmd=$NIX_BUILD_CORES
            npm run build -- ttf::IosevkaWitchcraft --jCmd=$NIX_BUILD_CORES
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            fontdir="$out/share/fonts/truetype"
            install -d "$fontdir"
            install "dist/IosevkaCode/TTF"/* "$fontdir"
            install "dist/IosevkaTerminal/TTF"/* "$fontdir"
            install "dist/IosevkaWitchcraft/TTF"/* "$fontdir"
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
