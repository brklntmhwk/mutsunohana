{
  description = "Mutsunohana";
  
  outputs = { ... }: {
    templates = {
      rust = {
        path = ./rust;
        description = "Rust";
      };
    };
  };
}
