#!/usr/bin/env bash

NOTIFY_TITLE="File Search"

## THEME SETUP
THEME_OVERRIDE="configuration {show-icons:false;} prompt {background-color: @accent;} element selected {background-color: @accent;} button selected {text-color: @accent;} textbox {text-color: @accent;}"

if ! command -v fd &> /dev/null; then
    notify-send "$NOTIFY_TITLE" "Error: 'fd' is not installed."
    exit 1
fi

## FILE SEARCH SELECTION
# Search files in $HOME while ignoring git noise
chosen=$(fd --type f --hidden --exclude .git --base-directory "$HOME" | \
    rofi -dmenu -i -p "Find" -theme-str "$THEME_OVERRIDE")

## OPENING LOGIC
if [ -n "$chosen" ]; then
    full_path="$HOME/$chosen"
    notify-send "$NOTIFY_TITLE" "Opening: $chosen"
    
    # Open file and detach process
    xdg-open "$full_path" > /dev/null 2>&1 & disown
fi
