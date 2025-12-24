# Core packages: Wayland, Mesa, Qt6
{ pkgs, wrapWithNixGL, quickshellPkg }:

with pkgs; [
  (wrapWithNixGL quickshellPkg)

  # Graphics/Wayland
  mesa
  libglvnd
  egl-wayland
  wayland

  # Qt6
  qt6.qtbase
  qt6.qtsvg
  qt6.qttools
  qt6.qtwayland
  qt6.qtdeclarative
  qt6.qtimageformats
  kdePackages.qtshadertools
  kdePackages.syntax-highlighting
]
