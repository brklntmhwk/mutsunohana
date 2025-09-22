{
  description = "Mutsunohana";
  
  outputs = { ... }: {
    templates = {
      rust = {
        path = ./rust/fenix-crane;
        description = "Rust development environment template";
      };
      rust-with-toolchain = {
        path = ./rust/fenix-crane-with-toolchain-file;
        description = ''
          Rust development environment template with rust-toolchain.toml
        '';
      };
    };
  };
}
