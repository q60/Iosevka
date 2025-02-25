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
    in {
      packages = {
        default = import ./default.nix {inherit pkgs;};
      };

      apps.default = utils.lib.mkApp {drv = self.packages.${system}.default;};
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [nodejs_23 ttfautohint];
      };
    });
}
