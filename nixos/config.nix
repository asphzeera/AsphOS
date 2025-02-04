{ inputs, config, pkgs, lib, ... }:

let
	tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
	session = "${pkgs.hyprland}/bin/Hyprland";
	username = "asph";
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware.nix
      ./extra.nix
      ./config/fonts.nix
      ./config/scripts/script.nix
      ./config/nvidia.nix
      inputs.home-manager.nixosModules.home-manager
     ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Flake
  nix.settings.experimental-features = [ "nix-command" "flakes"];
  
  environment.variables.EDITOR = "neovim"; 

  home-manager = {
	extraSpecialArgs = { inherit inputs; };
	users = {
		asph = import /home/asph/.config/home-manager/home.nix;
	};
  };


  # Styling Options
  stylix = {
    enable = true;
    image = ./config/wallpapers/montana.jpg; 
    # base16Scheme = {
    #   base00 = "232136";
    #   base01 = "2a273f";
    #   base02 = "393552";
    #   base03 = "6e6a86";
    #   base04 = "908caa";
    #   base05 = "e0def4";
    #   base06 = "e0def4";
    #   base07 = "56526e";
    #   base08 = "eb6f92";
    #   base09 = "f6c177";
    #   base0A = "ea9a97";
    #   base0B = "3e8fb0";
    #   base0C = "9ccfd8";
    #   base0D = "c4a7e7";
    #   base0E = "f6c177";
    #   base0F = "56526e";
    # };
    polarity = "dark";
    opacity.terminal = 0.8;
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
    cursor.size = 24;
    fonts = {
        monospace = {
      # Atualize para o novo namespace e pacote individual
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };


  users.users.asph = {
    isNormalUser = true;
    description = "asph";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.hyprland.enable = true;
 
   services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${session}";
        user = "${username}";
      };
      default_session = {
        command = "${tuigreet} --greeting 'Bem vindo ASAPH!' --asterisks --remember --remember-user-session --time -cmd ${session}";
        user = "asph";
      };
    };
  };

  environment.systemPackages = with pkgs; [

  #Hellwal
  swww

  #Editor
  neovim 
  #Coisas daqueles que programam dores
  git 
  wget

  #Terminal
  kitty

  #Navegador
  firefox

  #Jogo
  osu-lazer-bin

  #firefogo
  pywalfox-native

  #CADE MEU MINININHO DE PAPAI
  wofi

  #Nix
  home-manager
  ];


  system.stateVersion = "24.11"; 
}
