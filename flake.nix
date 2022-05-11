{
  description = "haskell-template's description";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";

    # For Rust development.
    nci.url = "github:yusdacra/nix-cargo-integration";
    nci.inputs.nixpkgs.follows = "nixpkgs";
  };
  # We use flake-utils to, effectively, allow us to pass this function:
  # 
  #  Set Input -> System -> Set Output
  #
  # cf. https://github.com/NixOS/nix/issues/3843#issuecomment-661720562
  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem
      (system:
        let 
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        in rec {
          # Project "flakes" are also parametrized by inputs and system.
          projects = {
            haskell = import ./haskell { inherit inputs system; };
            rust = import ./rusty { inherit inputs system; };
          };
          packages =
            projects.haskell.packages
            // projects.rust.packages;
          apps =
            projects.haskell.apps;
          devShells =
            projects.haskell.devShells
            // projects.rust.devShells
            // {
              default =
                (import ./nix/mergeDevShells.nix { inherit pkgs; })
                  (pkgs.lib.attrsets.attrValues (projects.haskell.devShells // projects.rust.devShells));
            };
          # Default derivations.
          devShell =
            inputs.self.devShells.${system}.default;
          defaultPackage = inputs.self.packages.${system}.haskell;
        }
      )
    // {
      # Specify the systems Hercules CI must build, 
      # https://docs.hercules-ci.com/hercules-ci/guides/upgrade-to-agent-0.9/#_upgrade_your_repositories
      herculesCI.ciSystems = [ "x86_64-linux" ];
    };
}
