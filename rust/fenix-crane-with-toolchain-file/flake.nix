{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    crane.url = "github:ipetkov/crane";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        {
          config,
          lib,
          pkgs,
          system,
          commonArgs,
          craneLib,
          rustToolchain,
          ...
        }:
        {
          _module.args = {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ inputs.fenix.overlays.default ];
            };

            rustToolchain = inputs.fenix.packages.fromToolchainFile {
              file = ./rust-toolchain.toml;
              # TODO: replace this with the hash you will see in the error message
              # at your first attempt to execute `nix develop`.
              sha256 = lib.fakeSha256;
            };

            # Override the toolchain defined in the toolchain file.
            craneLib = (inputs.crane.mkLib pkgs).overrideToolchain (_: rustToolchain);

            commonArgs = {
              # For more details, see:
              # https://crane.dev/source-filtering.html?highlight=craneLib.buildPackage#source-filtering
              #
              # Omit non-Rust/non-Cargo related files from the source tree.
              src = craneLib.cleanCargoSource (craneLib.path ./.);

              buildInputs =
                builtins.attrValues {
                  # Add additional build inputs required at build time and runtime here.
                  # inherit (pkgs)
                  # openssl;
                }
                ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.libiconv ];

              nativeBuildInputs = builtins.attrValues {
                # Add additional build inputs required at build time only here.
                # inherit (pkgs)
                # pkg-config;
              };
            };
          };

          packages.default = craneLib.buildPackage (
            commonArgs
            // {
              cargoArtifacts = craneLib.buildDepsOnly commonArgs;
            }
          );

          devShells.default = craneLib.devShell {
            packages =
              (commonArgs.buildInputs or [ ])
              ++ (commonArgs.nativeBuildInputs or [ ])
              ++ builtins.attrValues {
                inherit (pkgs)
                  rust-analyzer-nightly # From fenix
                  ;
              };

            RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              actionlint.enable = true;
              nixfmt.enable = true;
              # 'nixfmt-rfc-style' is deprecated and will be removed in the future.
              # nixfmt-rfc-style.enable = true;
              rustfmt.enable = true;
              taplo.enable = true;
            };
          };
        };
    };
}
