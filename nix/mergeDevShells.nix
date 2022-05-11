{ pkgs, ... }:

# Merge multiple devShells into one, such that entering the resulting
# dev shell puts one in the environment of all the input dev shells.
envs:
pkgs.mkShell (builtins.foldl'
  (a: b:
    # Standard shell attributes
    {
      buildInputs = (a.buildInputs or []) ++ (b.buildInputs or []);
      nativeBuildInputs = (a.nativeBuildInputs or []) ++ (b.nativeBuildInputs or []);
      propagatedBuildInputs = (a.propagatedBuildInputs or []) ++ (b.propagatedBuildInputs or []);
      propagatedNativeBuildInputs = (a.propagatedNativeBuildInputs or []) ++ (b.propagatedNativeBuildInputs or []);
      shellHook = (a.shellHook or "") + "\n" + (b.shellHook or "");
    } //
    # Environment variables
    (
      let
        isUpperCase = s: pkgs.lib.strings.toUpper s == s;
        filterUpperCaseAttrs = attrs: pkgs.lib.attrsets.filterAttrs (n: _: isUpperCase n) attrs;
      in
      filterUpperCaseAttrs a // filterUpperCaseAttrs b
    )
  )
  (pkgs.mkShell { })
  envs)
