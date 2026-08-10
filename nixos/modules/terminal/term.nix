{ den, ... }:{
  den.aspects.terminal = {
    nixos = { pkgs, ... }:{
      programs.foot = {
        enable = true;
      };
      programs.appimage.enable = true;
      programs.bash = {
        promptInit = ''
            [ -f ~/.cache/hellwal/variables.sh ] && source ~/.cache/hellwal/variables.sh
            [ -f ~/.cache/hellwal/terminal.sh ] && sh ~/.cache/hellwal/terminal.sh
        '';
      };
      programs.direnv.enable = true;
      environment.systemPackages = [
        pkgs.fzf
        pkgs.appimage-run
        pkgs.ncspot
        pkgs.direnv
        pkgs.nix-direnv
        pkgs.go
        pkgs.gcc
        pkgs.flutter
      ];      
      environment.shellAliases = {
        rb = "sudo nixos-rebuild switch --file /etc/nixos/default.nix -A flake.nixosConfigurations.casita";
        cf = "cd /etc/nixos/modules";
        niriN = "niri msg output HDMI-A-1 transform normal";
        niriL = "niri msg output HDMI-A-1 transform 90";
        suhx = "sudo -E hx";
        java-env = "nix flake init -t /etc/nixos/templates#java";
        c-env = "nix flake init -t /etc/nixos/templates#c";
      };
      users.users.asaph.maid.file = {
        home.".config/foot/foot.ini".source = ./foot.ini;
        home.".config/helix/config.toml".source = ./helix/helix.toml;
        home.".config/helix/languages.toml".source = ./helix/languages.toml;
      };
    };
  };
}
