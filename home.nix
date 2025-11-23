{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./config/nixvim.nix # Nixvim HM module
    ./config/noctalia.nix # Noctalia QuickShell wiring (fronm ddubsos)
    ./config/vscode.nix
    ./config/zsh.nix
    ./config/yazi/default.nix
  ];
  home = {
    username = lib.mkDefault "dwilliams";
    homeDirectory = lib.mkDefault "/home/dwilliams";
    stateVersion = "25.11";
    sessionVariables = {
      GTK_THEME = "Adwaita:dark";
    };
    packages = [
      (pkgs.writeShellScriptBin "rofi-legacy.menu" ''
        rofi -config ~/.config/rofi/legacy.config.rasi -show drun
      '')
      (pkgs.writeShellScriptBin "config-menu" ''
        #!/usr/bin/env bash
        set -euo pipefail

        EDITOR_BIN="${EDITOR:-nvim}"
        TERM_BIN="${TERMINAL:-}"

        pick_term() {
          if [ -n "${TERM_BIN}" ] && command -v "$TERM_BIN" >/dev/null 2>&1; then
            echo "$TERM_BIN"; return
          fi
          for t in kitty foot alacritty gnome-terminal konsole xterm; do
            if command -v "$t" >/dev/null 2>&1; then echo "$t"; return; fi
          done
          echo ""
        }

        repo="$HOME/Projects/ddubs/hyprland-btw"

        declare -A files=(
          ["flake.nix"]="$repo/flake.nix"
          ["home.nix"]="$repo/home.nix"
          ["configuration.nix"]="$repo/configuration.nix"
          ["hardware-configuration.nix"]="$repo/hardware-configuration.nix"
          ["config/hypr/hyprland.conf"]="$repo/config/hypr/hyprland.conf"
          ["config/hypr/binds.conf"]="$repo/config/hypr/binds.conf"
          ["config/hypr/env.conf"]="$repo/config/hypr/env.conf"
          ["config/hypr/startup.conf"]="$repo/config/hypr/startup.conf"
          ["config/hypr/WindowRules.conf"]="$repo/config/hypr/WindowRules.conf"
          ["config/hypr/appearance.conf"]="$repo/config/hypr/appearance.conf"
          ["config/hypr/hyprpaper.conf"]="$repo/config/hypr/hyprpaper.conf"
          ["config/packages.nix"]="$repo/config/packages.nix"
          ["config/fonts.nix"]="$repo/config/fonts.nix"
          ["config/.zshrc-personal"]="$repo/config/.zshrc-personal"
          ["config/.bashrc-personal"]="$repo/config/.bashrc-personal"
          ["config/kitty/kitty.conf"]="$repo/config/kitty/kitty.conf"
        )

        choice="$(printf '%s\n' "${!files[@]}" | sort | rofi -dmenu -i -config "$HOME/.config/rofi/config-menu.rasi" -p ' Edit Config')"
        [ -z "${choice}" ] && exit 0
        target="${files[$choice]}"

        mkdir -p "$(dirname "$target")"
        if [ ! -e "$target" ]; then
          : > "$target"
        fi

        term="$(pick_term)"
        if [ -n "$term" ] && [[ "$EDITOR_BIN" =~ ^(nvim|vim|vi|nano|helix|hx)$ ]]; then
          exec "$term" -e "$EDITOR_BIN" "$target"
        else
          "$EDITOR_BIN" "$target" >/dev/null 2>&1 & disown
        fi
      '')
    ];
  };

  programs = {
    neovim = {
      enable = false; # Now managed by nixvim.nix
      defaultEditor = true;
    };
    bash = {
      enable = true;
      shellAliases = {
        ll = "eza -la --group-dirs-first --icons";
        v = "nvim";
        rebuild = "sudo nixos-rebuild switch --flake ~/hyprland-btw/";
        update = "nix flake update --flake ~/hyprland-btw && sudo nixos-rebuild switch --flake ~/hyprland-btw/";
      };
      # The block below is for commands that should run every time a terminal starts.
      initExtra = ''
        # Source the personal file for all interactive shell sessions
        if [ -f ~/.bashrc-personal ]; then
         source ~/.bashrc-personal
        fi
      '';
      profileExtra = ''
        if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
          #exec uwsm start -S hyprland-uwsm.desktop
          export GTK_THEME=Adwaita:dark
          exec Hyprland
        fi
      '';
    };

    #  Enables seemless zoxide integration
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

    eza = {
      enable = true;
      icons = "auto";
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      git = true;
      extraOptions = [
        "--group-directories-first"
        "--no-quotes"
        "--header" # Show header row
        "--git-ignore"
        # "--time-style=long-iso" # ISO 8601 extended format for time
        "--classify" # append indicator (/, *, =, @, |)
        "--hyperlink" # make paths clickable in some terminals
      ];
    };
  };

  #  Help consistently theme appps 
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
    };
    gtk4.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
    };
  };

  # Seed wallpapers once into ~/Pictures/Wallpapers (Noctalia default), without overwriting user changes
  home.activation.seedWallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu
    SRC=${./config/wallpapers}
    DEST="$HOME/Pictures/Wallpapers"
    mkdir -p "$DEST"
    # Copy each file only if it doesn't already exist
    find "$SRC" -maxdepth 1 -type f -print0 | while IFS= read -r -d $'\0' f; do
      bn="$(basename "$f")"
      if [ ! -e "$DEST/$bn" ]; then
        cp "$f" "$DEST/$bn"
      fi
    done
  '';

  # Config apps
  home.file.".config/hypr".source = ./config/hypr;
  home.file.".config/waybar".source = ./config/waybar;
  home.file.".config/fastfetch".source = ./config/fastfetch;
  home.file.".config/kitty".source = ./config/kitty;
  home.file.".config/foot".source = ./config/foot;
  home.file.".bashrc-personal".source = ./config/.bashrc-personal;
  home.file.".zshrc-personal".source = ./config/.zshrc-personal;
  home.file.".config/tmux/tmux.conf".source = ./config/tmux.conf;
  home.file.".config/starship.toml".source = ./config/starship.toml;
  home.file.".config/rofi/legacy.config.rasi".source = ./config/rofi/legacy.config.rasi;
  home.file.".config/rofi/legacy-rofi.jpg".source = ./config/rofi/legacy-rofi.jpg;
  home.file.".config/rofi/config-menu.rasi".source = ./config/rofi/config-menu.rasi;
}
