{
  pkgs,
  inputs,
  lib,
  ...
}: let
  noctaliaPath = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  configDir = "${noctaliaPath}/share/noctalia-shell";
in {
  # Ensure QuickShell is available to run `qs -c noctalia-shell`.
  home.packages = [ pkgs.quickshell ];

  # Seed Noctalia config once into ~/.config/quickshell/noctalia-shell, then leave it writable
  home.activation.seedNoctaliaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu
    DEST="$HOME/.config/quickshell/noctalia-shell"
    SRC="${configDir}"

    if [ ! -d "$DEST" ]; then
      mkdir -p "$HOME/.config/quickshell"
      cp -R "$SRC" "$DEST"
      chmod -R u+rwX "$DEST"

      # Try to enable dock exclusive zone and theme-by-wallpaper in common formats
      # 1) JSON: set any "exclusive": false to true
      find "$DEST" -type f -name '*.json' -print0 | while IFS= read -r -d '' f; do
        sed -i 's/\("exclusive"[[:space:]]*:[[:space:]]*\)false/\1true/g' "$f" || true
        sed -i 's/\("themeByWallpaper"[[:space:]]*:[[:space:]]*\)false/\1true/g' "$f" || true
        # Set wallpaperDir if present
        sed -i 's#\("wallpaperDir"[[:space:]]*:[[:space:]]*\)"[^"]*"#\1"'"$HOME"'/Pictures/Wallpapers"#g' "$f" || true
      done

      # 2) YAML/YML: set any exclusive: false to true, themeByWallpaper: false to true
      find "$DEST" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 | while IFS= read -r -d '' f; do
        sed -i 's/\(exclusive[[:space:]]*:[[:space:]]*\)false/\1true/g' "$f" || true
        sed -i 's/\(themeByWallpaper[[:space:]]*:[[:space:]]*\)false/\1true/g' "$f" || true
        # naive wallpaperDir replacement if key exists
        sed -i 's#\(wallpaperDir[[:space:]]*:[[:space:]]*\).*#\1"'"$HOME"'/Pictures/Wallpapers"#g' "$f" || true
      done
    fi
  '';
}
