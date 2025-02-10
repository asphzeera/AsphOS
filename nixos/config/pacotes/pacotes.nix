{ inputs, config, lib, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [

  #Hellwal
  swww

  #Editor
  neovim
  obsidian

  #Ate me esqueci, AH, lembrei
  jamesdsp

  #Coisas daqueles que programam dores
  git 
  wget
  fzf

  #Terminal
  alacritty 
  st

  #Navegador
  firefox

  #Jogo
  osu-lazer-bin

  #firefogo
  pywalfox-native

  #CADE MEU MINININHO DE PAPAI
  wofi
  vesktop

  #Nix
  home-manager
  ];

}
