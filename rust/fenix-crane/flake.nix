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
    let
      # Specify either of the channel or the profile.
      # For more details, see:
      # https://github.com/nix-community/fenix?tab=readme-ov-file#toolchain

      # Channel of the Rust toolchain ("beta" or "stable")
      # channel = "stable";

      # Profile of the Rust toolchain ("default", "mininal", or "complete")
      profile = "default";
    in
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
          ...
        }:
        {
          _module.args = {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ inputs.fenix.overlays.default ];
            };

            # Override the toolchain defined based on the profile specified above.
            # The toolchain attr implies that it comes with all the components.
            craneLib = (inputs.crane.mkLib pkgs).overrideToolchain inputs.fenix.packages.${system}.${profile}.toolchain;

            # Override the toolchain defined based on the profile specified above.
            # craneLib = (inputs.crane.mkLib pkgs).overrideToolchain
            #   inputs.fenix.packages.${channel}.toolchain;

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

            RUST_SRC_PATH = "${inputs.fenix.packages.${system}.${profile}.rust-src}/lib/rustlib/src/rust/library";
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              actionlint.enable = true;
              nixfmt.enable = true;
              # 'nixfmt-rfc-style' is deprecated and will be removed in the future.
              # nixfmt-rfc-style.enable = true;
              rustfmt.enable = true;
            };
          };
        };
    };
}
