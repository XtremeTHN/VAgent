{
  pkgs ? import <nixpkgs> {},
}:

pkgs.stdenv.mkDerivation {
  pname = "KAgent";
  version = "0.1";
  src = pkgs.fetchFromGitHub {
   owner = "XtremeTHN";
   repo = "KAgent";
   rev = "layer";
   sha256 = "sha256-TVc/XLtMwWj/GL+vpzBmWPCaIH/59ppeQRkAkaFuuIg=";
  };
  
  nativeBuildInputs = with pkgs; [
    vala
    pkg-config
    meson
    ninja
    desktop-file-utils
    wrapGAppsHook4
    blueprint-compiler
  ];

  buildInputs = with pkgs; [
    glib
    gtk4
    libadwaita
    polkit
    gtk4-layer-shell
  ];
}
