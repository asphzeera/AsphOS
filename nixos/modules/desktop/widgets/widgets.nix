{ den, ... }: {
  den.aspects.widgets = {
    nixos = { pkgs, ... }: 
      let
      in {
      environment.systemPackages = [
        pkgs.waybar
        pkgs.hellwal
      ];
      users.users.asaph = {
        maid = {
          file.home.".config/hellwal/templates/waybar-colors.css".source = ./hellwal/templates/waybar-colors.css;
          file.home.".config/hellwal/templates/foot-colors.ini".source = ./hellwal/templates/foot-colors.ini;
          file.home.".config/hellwal/templates/rofi.rasi".source = ./hellwal/templates/rofi.rasi;
          file.home.".config/hellwal/templates/rofi.rasinc".source = ./hellwal/templates/rofi.rasinc;
          file.home.".config/hellwal/templates/helix-theme.toml".source = ./hellwal/templates/helix-theme.toml;
        
          file.home.".config/waybar/config.jsonc".source = ./waybar/config.jsonc;
          file.home.".config/waybar/style.css".source = ./waybar/style.css;
        };
      };
      fonts.packages = [
        pkgs.nerd-fonts.symbols-only
      ];
    };
  };
}
