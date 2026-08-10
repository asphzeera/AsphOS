{ den, ... }: {
  den.aspects.scripts = {
    nixos = { pkgs, ... }:
      let
        changewall = pkgs.writeShellScriptBin "changewall" ''
            if [ -z "$1" ]; then
              echo "Uso: changewall /caminho/para/imagem.png"
              exit 1
            fi
            mkdir -p ~/.config/hellwal/templates
            mkdir -p ~/.cache/hellwal

            rm -f ~/.config/hellwal/templates/*
            cp -L ${../../desktop/widgets/hellwal/templates}/* ~/.config/hellwal/templates/
  
            chmod 644 ~/.config/hellwal/templates/*

            ${pkgs.swww}/bin/swww img "$1" --transition-type center
            ${pkgs.hellwal}/bin/hellwal -i "$1"
            mkdir -p ~/.config/helix/themes
            cp ~/.cache/hellwal/helix-theme.toml ~/.config/helix/themes/hellwal.toml

            pkill -USR2 waybar

            echo "Templates processados com sucesso!"
        '';
      wallmenu = pkgs.writeShellScriptBin "wallmenu" ''
          WALL_DIR="$HOME/Images/Wallpapers"
          ROFI_CMD="${pkgs.rofi}/bin/rofi"
          COLORS_FILE="$HOME/.cache/hellwal/rofi.rasi"

          if [ -f "$COLORS_FILE" ]; then
              COLOR_IMPORT="@import \"$COLORS_FILE\""
          else
              COLOR_IMPORT="* { active-background: #5e81ac; background: #2e3440; foreground: #eceff4; }"
          fi

          THEME_GALLERY="
            $COLOR_IMPORT
            configuration { show-icons: true; } 
            window { 
                width: 90%; anchor: center; location: center; padding: 20px; 
                border: 3px; border-color: @active-background; background-color: @background; 
                border-radius: 15px;
            } 
            mainbox { background-color: transparent; children: [ inputbar, listview ]; }
            inputbar { background-color: transparent; margin: 0px 0px 20px 0px; padding: 10px; }
            entry { background-color: transparent; text-color: @foreground; placeholder: \"Search wallpapers...\"; }
            listview { columns: 6; lines: 1; fixed-height: false; spacing: 20px; background-color: transparent; } 
            element { orientation: vertical; padding: 15px; spacing: 10px; border-radius: 12px; background-color: transparent; } 
            element-icon { size: 250px; horizontal-align: 0.5; background-color: transparent; } 
            element-text { horizontal-align: 0.5; vertical-align: 0.5; background-color: transparent; text-color: @foreground; } 
            element selected { background-color: @active-background; } 
            element selected text { text-color: @background; }
          "

          if [ ! -d "$WALL_DIR" ]; then
              ${pkgs.libnotify}/bin/notify-send "Wallmenu" "Erro: Pasta $WALL_DIR não encontrada."
              exit 1
          fi
          shopt -s nullglob
          FILES=("$WALL_DIR"/*.{jpg,jpeg,png,gif,webp,bmp})

          if [ ''${#FILES[@]} -eq 0 ]; then
              ${pkgs.libnotify}/bin/notify-send "Wallmenu" "Nenhuma imagem encontrada em $WALL_DIR"
              exit 1
          fi

          ROFI_LIST=""
          for img in "''${FILES[@]}"; do
              filename=$(basename "$img")
              ROFI_LIST+="$filename\0icon\x1f$img\n"
          done

          CHOSEN=$(echo -e -n "$ROFI_LIST" | $ROFI_CMD -dmenu -i -p "Wallpapers" -theme-str "$THEME_GALLERY")

          if [ -n "$CHOSEN" ]; then
              # BACK-END: Chama o seu changewall original
              ${changewall}/bin/changewall "$WALL_DIR/$CHOSEN"
          fi
        '';
       in
    {
      environment.systemPackages = [
        changewall
        wallmenu
      ];
    };
  };
}
