{ inputs, system }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  # Subflake for Rust development environment and build
  rustFlake = inputs.nci.lib.makeOutputs {
    # Documentation and examples:
    # https://github.com/yusdacra/rust-nix-templater/blob/master/template/flake.nix
    root = ./.;
    overrides = {
      shell = common: prev: {
        packages = prev.packages ++ [
          pkgs.rust-analyzer
        ];
        env = prev.env ++ [
          # For downstream projects (eg: Haskell) to access the Rust
          # library in their runtime tools like repls and language
          # servers.
          (pkgs.lib.nameValuePair "LD_LIBRARY_PATH" "${rustFlake.packages.${system}.rusty}/lib")
        ];
      };
    };
  };
in
{
  # Used by `nix build ...`
  packages = {
    rusty = rustFlake.packages.${system}.rusty;
  };
  # Used by `nix develop ...`
  devShells = {
    rusty = rustFlake.devShell.${system};
  };
}
