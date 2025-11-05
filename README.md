# VAgent
A polkit authentication agent written in vala using gtk4 and libadwaita.

<img width="1921" height="1081" alt="Preview" src="https://github.com/user-attachments/assets/c88160df-ee1e-41c9-b72e-57cad41cf981" />


## Building
Nix
```
nix build
```

Meson
```
meson setup build
cd build
meson compile
```

## Installing
### NixOS
Add this repository to your flake inputs
```nix
# flake.nix
inputs.vagent = {
  url = "github:XtremeTHN/VAgent;
  inputs.nixpkgs.follows = "nixpkgs";
};
```
Then add vagent to the `home.packages` or `environment.systemPackages`.
```nix
# home.nix
home.packages = [
  inputs.vagent.packages."x86_64-linux".default
];
```

### Meson
```
meson setup build
meson install -C build
```
