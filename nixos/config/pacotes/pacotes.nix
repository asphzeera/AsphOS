{ inputs, config, lib, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [

  #Coisas daqueles que programam dores
  git 
  wget
  fzf
  st

  #Hellwal
  swww

  #CADE MEU MINININHO DE PAPAI
  wofi
  vesktop

  #Editor
  neovim
  obsidian

  #Ate me esqueci, AH, lembrei
  jamesdsp

  #Navegador
  firefox

  #Terminal
  alacritty

  #Nix
  home-manager

  #Jogo
  osu-lazer-bin

  #firefogo
  pywalfox-native

  #Editores de Imagem Video etc
  gimp-with-plugins
  inkscape-with-extensions

  ];

}
