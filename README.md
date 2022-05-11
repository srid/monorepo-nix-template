# monorepo-nix-template

A simple demonstration of writing a top-level `flake.nix` that delegates to inner `default.nix` (flake alike). This pattern is useful in monorepos with many sub-projects written in different programming languages.

Files of interest:

- `flake.nix` -- top-level flake
- `haskell/project.nix` -- haskell flake-alike
- `rust/project.nix` -- rust flake-alike

Features

- Haskell app statically links to Rust library
- Works on Linux and macOS (M1)
- IDE experience works for both languages through HLS.
- Autoformat by treefmt

## Haskell

The Haskell programs links with the Rust library.

```
nix develop -c sh -c "cd ./haskell && cabal run"
```

## Rust

```
nix develop -c sh -c "cd ./rusty && cargo build"
```

## Nix

Run the full program,

```
nix run
```

Just build it,

```
nix build
```
