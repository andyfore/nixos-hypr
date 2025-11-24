{ pkgs }:

pkgs.writeShellScriptBin "keybinds" ''
  # Parse binds.conf and create a rofi menu showing keybinds with descriptions
  # $mainMod is replaced with SUPER for clarity in the display
  
  binds_file="$HOME/.config/hypr/binds.conf"
  
  if [ ! -f "$binds_file" ]; then
    echo "Error: $binds_file not found" >&2
    exit 1
  fi
  
  # Extract all bindd lines, parse them, and format for rofi
  # Replace $mainMod with SUPER in display only
  menu_entries=$(grep "^bindd = " "$binds_file" | sed 's/.*bindd = //g' | while IFS= read -r line; do
    # Extract modifier(s), key, and description from the line
    # Format: "MODIFIER(S), KEY, DESCRIPTION, command, args"
    modifiers=$(echo "$line" | cut -d',' -f1 | xargs)
    key=$(echo "$line" | cut -d',' -f2 | xargs)
    description=$(echo "$line" | cut -d',' -f3 | xargs)
    
    # Replace $mainMod with SUPER in modifiers for display
    modifiers=$(echo "$modifiers" | sed 's/\$mainMod/SUPER/g')
    
    # Format: "MODIFIERS + KEY: Description"
    if [ -n "$modifiers" ] && [ -n "$key" ] && [ -n "$description" ]; then
      echo "$modifiers + $key: $description"
    fi
  done)
  
  # Display the menu using rofi with legacy config style
  selected=$(echo "$menu_entries" | \
    rofi -config ~/.config/rofi/legacy.config.rasi \
         -dmenu -p "Keybinds" -i -no-custom)
  
  # If a keybind was selected, copy it to clipboard and notify
  if [ -n "$selected" ]; then
    echo "$selected" | wl-copy
    notify-send "Keybind" "Copied to clipboard: $selected"
  fi
''
