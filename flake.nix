{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      nativeBuildInputs = with pkgs; [
        meson
        ninja
        pkg-config
        vala
        wrapGAppsHook4
        blueprint-compiler
        gobject-introspection
      ];

      buildInputs = with pkgs; [
        gtk4
        libadwaita
        glib
        polkit
        gtk4-layer-shell
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        inherit nativeBuildInputs buildInputs;

        packages = with pkgs; [
          vala-language-server
          uncrustify
          gdb
        ];
      };

      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "kagent";
        version = "0.1";
        src = ./.;
        inherit nativeBuildInputs buildInputs;
      };
    };
}
