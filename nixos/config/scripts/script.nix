{ pkgs, ... }:
let
  wallpapers_path = "/home/asph/asphos/nixos/config/wallpapers";

  setwall = pkgs.writeShellScriptBin "setwall" ''

    if [ "$1" != "" ] ; then 
        # generate palette and templates from given image
          hellwal --image "$wallpapers_path/$1"

    else
        # generate palette and templates from random image
          hellwal --image "$wallpapers_path/" --random
    fi


    # source variables so you have accesss to $colors and $wallpaper
    source ~/.cache/hellwal/variables.sh
     
    # apply wallpaper
    swww img "$wallpaper" \
      --transition-type="grow" \
      --transition-duration 2 \
      --transition-fps 165 \
      --resize="crop" \
      --invert-y

    # copy generated hellwal colors to pywal location, so pywalfox can understand it
    if [ -f ~/.cache/hellwal/colors.json ]; then
	    cp ~/.cache/hellwal/colors.json ~/.cache/wal/

    else
	    echo "Erro: colors.json não foi gerado!"
	    exit 1

    fi

    cp ~/.cache/hellwal/colors.json ~/.cache/wal/
    
    # update pywalfox
    pywalfox update
    
    # reload waybar with new colors
    wbar-reload
  '';

   wbar-reload = pkgs.writeShellScriptBin "wbar-reload" ''
    #!/usr/bin/env bash
    waybarPID=$(pgrep waybar)
    kill $waybarPID
    nohup waybar > /dev/null 2>&1 &
    echo "waybar reloaded!"
  '';

   sysconfupdate = pkgs.writeShellScriptBin "sysconfupdate" ''
    #!/usr/bin/env bash
    cd /home/asph/asphos/
    git pull
    sudo nixos-rebuild switch --flake ~/asphos/#Nix --impure
  '';
  sysconfrebuild = pkgs.writeShellScriptBin "sysconfrebuild" ''
    #!/usr/bin/env bash
    cd /home/asph/asphos/
    git add .
    git commit -m "nix config auto-commit"
    sudo nixos-rebuild switch --flake ~/asphos/#Nix --impure
  '';

  sysconfrebuildpush = pkgs.writeShellScriptBin "sysconfrebuildpush" ''
    #!/usr/bin/env bash
    cd /home/asph/asphos/
    git pull -rebase
    git add .
    git commit -m "Auto-update: $(date +"%Y-%m-%d %H:%M:%S")"
    sudo nixos-rebuild switch --flake ~/asphos/#Nix --impure

    if [ ! $? -eq "0" ]; then
      echo "Failed to rebuild..."
      exit
    else
      echo "Build successful, pushing changes to github:"
      git push origin main
    fi
  '';

 in {
 environment.systemPackages = with pkgs; [
  setwall
  wbar-reload
  sysconfupdate
  sysconfrebuild
  sysconfrebuildpush
];

}
