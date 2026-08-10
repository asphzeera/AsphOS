{ den, ... }: {
  den.aspects.rofi = {
    nixos = { pkgs, ... } :{
      environment.systemPackages = [
        pkgs.rofi
        pkgs.libnotify
      ];

      users.users.asaph.maid.file = {
        home.".config/rofi/wallpaper_dir".source = ./rofiConf/wallpaper_dir;
        home.".config/rofi/NoSearchConfig.rasi".source = ./rofiConf/NoSearchConfig.rasi;
        home.".config/rofi/config.rasi".source = ./rofiConf/config.rasi;

        home.".config/rofi/scripts/wallpaper_menu.sh".source =
          let
            script = pkgs.writeShellScriptBin "wallpaper_menu" (builtins.readFile ./scripts/wallpaper_menu.sh);
          in "${script}/bin/wallpaper_menu";

        home.".config/rofi/scripts/workflow-toogle.sh".source =
          let
            script = pkgs.writeShellScriptBin "workflow-toogle" (builtins.readFile ./scripts/workflow-toogle.sh);
          in "${script}/bin/workflow-toogle";
     };
  };
};
}
