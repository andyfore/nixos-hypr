{ pkgs, ... }: {
  #  Add packages below.

  environment.systemPackages = with pkgs; [
    ## Hyprland specific
    hyprpaper
    hyprshot
    hypridle
    hyprlock
    hyprpicker
    libnotify # send alerts
    xdg-desktop-portal-hyprland

    # Hyprland Related
    app2unit # launcher
    clipman
    cliphist
    grim
    quickshell
    slurp
    nwg-look
    rofi
    wofi
    waybar
    matugen
    wl-clipboard
    # Qt6 dependencies for quickshell-overview
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtwayland
    qt6.qt5compat
    qt6.qtmultimedia

    # Add your packages here
    atop
    bat
    btop
    bottom
    cargo
    clang
    curl
    coreutils
    dino # Jabber XMPP Client
    direnv # needed for zsh plugin and vscode
    fastfetch
    foot
    gajim # Japper XMPP client
    git
    gcc
    git
    gping
    google-chrome
    htop
    hyfetch
    inxi
    kitty
    bibata-cursors
    lunarvim # Alternate neovim (lvim)
    luarocks # LUA for nevoim
    mdcat
    mesa-demos # needed for inxi
    ncdu
    nh # Nix Helper
    nixd # nix lsp
    onefetch
    onlyoffice-desktopeditors
    pciutils
    ranger
    ripgrep
    rustup
    starship
    tmux #Terminal mux with hybridd ddubs-tonybtw config
    ugrep
    wget
    zig
  ];
}
