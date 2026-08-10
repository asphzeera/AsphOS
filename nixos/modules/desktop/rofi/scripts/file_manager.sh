#!/usr/bin/env bash

rofi_cmd="rofi -dmenu -theme ~/.config/rofi/NoSearchConfig.rasi"

current_dir="$HOME"

while true; do

    entries=""

    # parent option
    if [ "$current_dir" != "$HOME" ]; then
        entries="../\n"
    fi

    # folders
    while IFS= read -r dir; do
        name=$(basename "$dir")
        entries+="📁 $name\n"
    done < <(find "$current_dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort)

    # files with size
    while IFS= read -r file; do
        name=$(basename "$file")
        size=$(du -h "$file" | cut -f1)
        entries+="📄 $name    [$size]\n"
    done < <(find "$current_dir" -maxdepth 1 -type f 2>/dev/null | sort)

    selection=$(printf "$entries" | $rofi_cmd -p "$(basename "$current_dir")")

    [ -z "$selection" ] && exit

    # go up
    if [ "$selection" = "../" ]; then
        current_dir=$(dirname "$current_dir")
        continue
    fi

    name=$(echo "$selection" | sed 's/^📁 //; s/^📄 //; s/    .*//')

    path="$current_dir/$name"

    if [[ "$selection" == 📁* ]]; then
        current_dir="$path"
        continue
    fi

    if [[ "$selection" == 📄* ]]; then
        xdg-open "$path"
    fi

done
