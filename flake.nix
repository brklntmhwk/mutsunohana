# SPDX-FileCopyrightText: 2025 Ohma Togaki
# SPDX-License-Identifier: MIT
{
  description = ''
    Mutsunohana ー a forgotten name whispered for snow ー is the constellation of flakes:
    a gathering of crystalline patterns, each a template that descends like snow
    upon the vast landscape of creation ー ephemeral yet eternal, simple yet infinite.
  '';
  
  outputs = { ... }: {
    templates = {
      rust = {
        path = ./rust/basic;
        description = "Basic Rust development environment template";
      };
      rust-rmk = {
        path = ./rust/rmk-firmware;
        description = "Development environment for RMK Firmware projects";
      };
    };
  };
}
