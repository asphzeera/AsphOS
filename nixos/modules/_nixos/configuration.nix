{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      (import (import ../../npins).nix-maid).nixosModules.default
    ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "casita"; 

  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "pt_BR.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     useXkbConfig = true;  
  };

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.10"
  ];

  fileSystems."/mnt/dados" = {
    device = "/dev/disk/by-uuid/ae9b2e5c-051b-4680-89cf-e82036a8a659";
    fsType = "ext4";
    options = [ "users" "nofail" ];
  };

  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = ["nvidia"];
  services.input-remapper.enable = true;
  services.devmon.enable = true;
  services.gvfs.enable = true; 
  services.udisks2.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  environment.variables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  programs.firefox.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.PermitRootLogin = "no";
  };

  security.sudo.extraRules = [{
    users = [ "asaph" ];
    commands = [{
      command = "/run/current-system/sw/bin/systemctl";
      options = [ "NOPASSWD" ];
    }];
  }];
  security.polkit.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };
  systemd.services.greetd.serviceConfig.Type = "idle";
  services.dbus.enable = true;
  services.xserver.enable = true;
  services.xserver.xkb.layout = "br";
  services.xserver.xkb.variant = "nodeadkeys";
  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  users.users.asaph = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" ];
    packages = with pkgs; [
      tree
    ];
  };


  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    polkit_gnome
  ];

  system.stateVersion = "25.11"; 
}

