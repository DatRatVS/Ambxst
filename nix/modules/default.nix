# NixOS module for Ambxst
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.ambxst;
in {
  options.programs.ambxst = {
    enable = lib.mkEnableOption "Ambxst shell";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The Ambxst package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # Enable recommended services for full functionality
    services.power-profiles-daemon.enable = lib.mkDefault true;
    networking.networkmanager.enable = lib.mkDefault true;
  };
}
