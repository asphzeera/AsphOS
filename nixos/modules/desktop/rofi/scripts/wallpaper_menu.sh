#!/usr/bin/env bash

CONFIG_FILE="$HOME/.config/rofi/wallpaper_dir"
NOTIFY_TITLE="Wallpaper"

if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
fi

## THEME DEFINITIONS
THEME_GALLERY="
    configuration { show-icons: true; } 
    window { 
        width: 90%; 
        anchor: center; location: center;
        padding: 20px; 
    } 
    mainbox {
        background-color: transparent;
        children: [ inputbar, listview ];
    }
    inputbar {
        background-color: transparent;
        border: 0px;
        margin: 0px 0px 20px 0px;
        padding: 10px 0px;
    }
    entry {
        background-color: transparent;
        text-color: @fg-col;
    }
    listview { 
        columns: 6; lines: 1; 
        fixed-height: false; 
        fixed-columns: true; 
        cycle: false; 
        layout: vertical; flow: horizontal;
        spacing: 20px;
        background-color: transparent;
    } 
    element { 
        orientation: vertical; 
        padding: 20px; 
        spacing: 15px; 
        border-radius: 12px;
    } 
    element-icon { 
        size: 200px; 
        horizontal-align: 0.5; 
        background-color: transparent;
    } 
    element-text { 
        horizontal-align: 0.5; 
        vertical-align: 0.5; 
        expand: true;
        background-color: transparent;
    } 
    
    element selected { background-color: @wallpaper; } 
    textbox { text-color: @wallpaper; } 
"

THEME_PICKER="
    window { width: 40%; height: 50%; border-color: @wallpaper; }
    prompt { background-color: @wallpaper; text-color: @bg-col; }
    element selected { background-color: @wallpaper; }
    element-text { vertical-align: 0.5; }
    element-icon { size: 24px; }
"

## DIRECTORY BROWSER
pick_dir() {
    local current_dir="$HOME"
    while true; do
        dirs=$(find "$current_dir" -mindepth 1 -maxdepth 1 -type d -not -name '.*' -printf "%f\n" | sort)
        options="  Use This Folder\n..\n$dirs"
        
        # Prevent empty trailing newline ghost-boxes in the picker too
        options=$(echo "$options" | sed '/^$/d')
        chosen=$(echo -e -n "$options" | rofi -dmenu -i -p "$current_dir" -theme-str "$THEME_PICKER")
        
        if [ -z "$chosen" ]; then exit 1
        elif [ "$chosen" == "  Use This Folder" ]; then echo "$current_dir"; return 0
        elif [ "$chosen" == ".." ]; then current_dir=$(dirname "$current_dir")
        else current_dir="$current_dir/$chosen"; fi
    done
}

## MAIN LOGIC
if [ ! -f "$CONFIG_FILE" ]; then
    INIT_DIR=$(pick_dir)
    if [ -n "$INIT_DIR" ]; then echo "$INIT_DIR" > "$CONFIG_FILE"; else exit; fi
fi

WALL_DIR=$(eval echo $(cat "$CONFIG_FILE"))

# Populate gallery list with images
ROFI_LIST="Change the Directory\0icon\x1ffolder\n"
shopt -s nullglob
for img in "$WALL_DIR"/*.{jpg,jpeg,png,gif,webp,bmp}; do
    filename=$(basename "$img")
    ROFI_LIST+="$filename\0icon\x1f$img\n"
done

# Strip the trailing newline from the loop to prevent the empty blank box 
ROFI_LIST=$(echo "$ROFI_LIST" | sed 's/\\n$//')
CHOSEN=$(echo -e -n "$ROFI_LIST" | rofi -dmenu -i -p "Wallpapers" -theme-str "$THEME_GALLERY")

## ACTION HANDLER
if [ -z "$CHOSEN" ]; then
    exit
elif [ "$CHOSEN" == "Change the Directory" ]; then
    NEW_DIR=$(pick_dir)
    if [ -n "$NEW_DIR" ]; then
        echo "$NEW_DIR" > "$CONFIG_FILE"
        exec "$0"
    fi
else
    FULL_PATH="$WALL_DIR/$CHOSEN"
    notify-send "$NOTIFY_TITLE" "Setting wallpaper..."
    # Apply wallpaper with a grow transition
    swww img "$FULL_PATH" --transition-type grow --transition-step 90 --transition-fps 60
fi
