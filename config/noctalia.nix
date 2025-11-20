{ config, pkgs, inputs, lib, ... }:
let
  home = config.home.homeDirectory;
  system = pkgs.stdenv.hostPlatform.system;
  noctaliaPath = inputs.noctalia.packages.${system}.default;
  configDir = "${noctaliaPath}/share/noctalia-shell";
in {
  # Import the official Noctalia Home Manager module.
  # This provides `programs.noctalia-shell` and the user systemd service
  # that manages a writable GUI-driven config.
  imports = [ inputs.noctalia.homeModules.default ];

  # Make the Noctalia package available for this user (CLI, assets, etc.).
  home.packages = [
    noctaliaPath
  ];

  # Seed the Noctalia QuickShell shell code into ~/.config/quickshell/noctalia-shell
  # once, then leave it writable for GUI-driven edits.
  home.activation.seedNoctaliaShellCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu
    DEST="$HOME/.config/quickshell/noctalia-shell"
    SRC="${configDir}"

    if [ ! -d "$DEST" ]; then
      mkdir -p "$HOME/.config/quickshell"
      cp -R "$SRC" "$DEST"
      chmod -R u+rwX "$DEST"
    fi
  '';

  programs.noctalia-shell = {
    enable = true;

    # Run Noctalia via a per-user systemd service instead of manually
    # seeding QuickShell config. This keeps the on-disk config writable
    # by the GUI while still letting us provide better defaults via Nix.
    systemd.enable = true;

    # Provide sane, user-relative defaults while keeping the config
    # writable by the GUI. These are *defaults*, not a full lock-down
    # of the config schema.
    settings = {
      # Use a generic terminal for app launcher (can be changed in GUI).
      appLauncher.terminalCommand = "xterm -e";

      # Dock behavior: enabled by default and overlapping windows instead of
      # reserving an exclusive zone.
      dock = {
        enabled = true;
        displayMode = "overlap";
      };

      # Paths that previously hard-coded /home/dwilliams are now derived
      # from the current user's home directory.
      general.avatarImage = "${home}/Pictures/ddubsos-mtn-purple-small.jpg";

      screenRecorder.directory = "${home}/Videos";

      wallpaper = {
        directory = "${home}/Pictures/Wallpapers";
        defaultWallpaper = "${home}/.config/quickshell/noctalia-shell/Assets/Wallpaper/noctalia.png";

        # We intentionally do *not* set per-monitor wallpaper entries here,
        # since those are highly machine-specific and better handled via the GUI.
      };
    };
  };
}
