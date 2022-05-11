{ inputs, system }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  inherit (pkgs.lib.trivial) pipe flip;
  inherit (pkgs.lib.lists) optionals;

  # Specify GHC version here. To get the appropriate value, run:
  #   nix-env -f "<nixpkgs>" -qaP -A haskell.compiler
  hp = pkgs.haskellPackages; # Eg: pkgs.haskell.packages.ghc921;
  # Specify your build/dev dependencies here.
  shellDeps = with hp; [
    cabal-fmt
    cabal-install
    ghcid
    haskell-language-server
    fourmolu
    hlint
    pkgs.nixpkgs-fmt
    pkgs.treefmt
  ];
  project = returnShellEnv:
    hp.developPackage {
      inherit returnShellEnv;
      name = "haskell-template";
      root = ./.;
      withHoogle = false;
      overrides = self: super: with pkgs.haskell.lib; {
        # Use callCabal2nix to override Haskell dependencies here
        # cf. https://tek.brick.do/K3VXJd8mEKO7
        # Example: 
        # > NanoID = self.callCabal2nix "NanoID" inputs.NanoID { };
        # Assumes that you have the 'NanoID' flake input defined.
        rusty = inputs.self.packages.${system}.rusty;
      };
      modifier = drv:
        pkgs.haskell.lib.overrideCabal drv
          (drv: {
            buildTools = (drv.buildTools or [ ]) ++ pkgs.lib.lists.optionals returnShellEnv shellDeps;
          });
    };

in
{
  # Used by `nix build ...`
  packages = {
    haskell = project false;
  };
  # Used by `nix run ...`
  apps = {
    haskell = {
      type = "app";
      program = "${inputs.self.packages.${system}.haskell}/bin/haskell-template";
    };
  };
  # Used by `nix develop ...`
  devShells = {
    haskell = project true;
  };
}
