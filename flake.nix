{
  description = "Flake for zero 2 production in rust";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    crisidevBaconLs.url = "github:crisidev/bacon-ls";
    crisidevBaconLs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, crisidevBaconLs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      bacon-ls = crisidevBaconLs.defaultPackage.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          rustc
          cargo
          rust-analyzer
          rustfmt
          clippy
          bacon
          bacon-ls
          vscode-extensions.vadimcn.vscode-lldb.adapter
        ];
        RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
        shellHook = ''
          echo "Let's learn Zero 2 production in Rust"
        '';
      };
    };
}
