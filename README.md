# Mutsunohana 卍 六花
> Mutsunohana ー a forgotten name whispered for snow ー is the constellation of flakes: a gathering of crystalline patterns, each a template that descends like snow upon the vast landscape of creation ー ephemeral yet eternal, simple yet infinite.

This is a collection of my [Nix Flakes](https://nixos.wiki/wiki/Flakes) templates mainly focused on providing a one-shot development environment for various projects across multiple programming languages.

For a specific programming language, each flake sets up a development shell that contains:

- The programming language implementation
- The language server
- Other miscellaneous tools required

## Usage

> [!NOTE]
> This repository requires Nix and its experimental Nix Flakes feature to be enabled.

To kick off your project, you are supposed to use these two commands from [the new Nix CLI](https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix):

- `nix flake init`: Creates a flake in the current directory from a template
- `nix develop`: Runs a bash shell that provides the build environment of a derivation

For example, this creates a flake file for a basic Rust project:

``` shell
nix flake init -t github:brklntmhwk/mutsunohana#rust
```

To enter into the development shell, run:

``` shell
nix develop
```

It generates a `flake.lock` file if not present simultaneously. You could also run `nix flake lock` to do so separately before the develop command.

Now you are all set. The next step could be scaffolding by:

- using a convenient CLI from the ecosystem (e.g., `cargo new`)
- cloning from a repository
- manually making directories and files
- and what-not

## License

This project is licensed under multiple licenses, compliant with [REUSE 3.3](https://reuse.software/spec-3.3/). License files are stored under the [LICENSES](./LICENSES/) directory and each file contains an SPDX license identifier in itself.

Importantly, all the template files are published under the [UNLICENSE](./LICENSES/Unlicense.txt).
