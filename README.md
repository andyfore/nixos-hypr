# hyprland-btw — Hyprland-on-NixOS (single-host)

Super simple NixOS + Hyprland configuration derived from the **tony,btw** example,
with a few additions:

- Modular drivers for AMD/Intel/NVIDIA GPUs and VM guest services
- Small install script for first-time setup on a single host
- Home Manager wiring for user-level config
- Added Noctalia-shell

### Inspiration

- Video: [`tony,btw` — Hyprland on NixOS](https://www.youtube.com/watch?v=7QLhCgDMqgw&t=138s)
- Config: [tony,btw GitHub](https://github.com/tonybanters)
- GUI: [Noctalia-shell](https://github.com/noctalia-dev/noctalia-shell)

> Default target is **a single host**, often running in a VM.
>
> - QEMU/KVM with VirtIO and 3D acceleration enabled
> - Can be installed from a live NixOS ISO (see Tony's video)
> - This repo now includes basic AMD/Intel/NVIDIA/Hybrid GPU + VM support out of the box.

### Important:

> Note: Currently the first-time you login `noctalia-shell` doesn't start
> Logout: `SUPER+SHIFT+Q` then back in. It will start normally after that
> I am working to resolve this issue

## Features:

### Hyprland

- `ly` login Manager
- Simple flake
- Simple Home Manager
- Noctalia shell
- Simple waybar as alternative
- NeoVIM configured by `nixvim`
- Tony,BTW's TMUX configuration

**Noctalia Shell**

![Noctalia Shell](config/images/ScreenShot-Noctalia.png)

![Noctalia Shell htop](config/images/ScreenShot-htop-noctalia.png)

**Waybar**

![Waybar](config/images/ScreenShot-waybar.png)

![Waybar htop](config/images/ScreenShot-htop-waybar.png)

## Installation:

### Quick install (script)

From a NixOS live system or an existing NixOS install:

```bash
nix-shell -p git
cd ~
git clone https://gitlab.com/your-remote/hyprland-btw.git
cd hyprland-btw
chmod +x ./install.sh
./install.sh
```

- The script:
  - Verifies you are on NixOS
  - Copies `/etc/nixos/hardware-configuration.nix` into this repo
  - Lets you set the timezone (or defaults to `America/New_York`)
  - Runs `sudo nixos-rebuild switch --flake .#hyprland-btw`

Non-interactive usage:

```bash
./install.sh --non-interactive
```

### Manual install

If you prefer to do things by hand:

```bash
nix-shell -p git
cd ~
git clone https://gitlab.com/your-remote/hyprland-btw.git
cd hyprland-btw
sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
sudo nixos-rebuild switch --flake .#hyprland-btw
```

## Drivers

Drivers are now modular, inspired by `ddubsos/modules/drivers`:

- `drivers.amdgpu.enable = true;` — AMD GPU support (ROCm symlink + `services.xserver.videoDrivers = [ "amdgpu" ]`)
- `drivers.intel.enable = true;` — Intel GPU support (VAAPI / VDPAU packages)
- `drivers.nvidia.enable = true;` — NVIDIA GPU support (`hardware.nvidia` + stable driver package)
- `vm.guest-services.enable = true;` — QEMU/Spice guest services (moved out of `services` in `configuration.nix`)

This project assumes **a single host**; there is no `specialArgs.host` logic or
per-host branching like in [ddubsOS](https://gitlab.com/dwilliam62/ddubsos).
Toggle only the one driver you actually need.

## Nix configuration files:

Below you can expand each Nix file to view its full contents.

<details>
<summary><code>flake.nix</code> – Flake entrypoint</summary>

```nix
{
  description = "Hyprland on Nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:nix-community/nixvim";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixvim, noctalia, ... }: {
    nixosConfigurations.hyprland-btw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users."your-username" = import ./home.nix;
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit inputs; };
          };
        }
      ];
    };
  };
}
```

</details>

<details>
<summary><code>configuration.nix</code> – System configuration</summary>

```nix
{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./config/packages.nix
      ./config/fonts.nix
    ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 40; # use ~50% of RAM for compressed swap (tweak as you like)
    priority = 100; # higher than any disk-based swap
  };

  networking = {
    hostName = "hyprland-btw";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  # Add services
  services = {
    # Disable TTY autologin; use a display manager (ly) instead.
    getty.autologinUser = null;
    openssh.enable = true;
    tumbler.enable = true;
    envfs.enable = true;
    libinput.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    displayManager.ly = {
      enable = true;
      settings = {
        animation = "matrix";
      };
    };
  };

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = false;
    };
    firefox.enable = true;
    thunar.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."your-username" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "25.11"; # Did you read the comment?

}
```

</details>

<details>
<summary><code>home.nix</code> – Home Manager configuration</summary>

```nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./config/nixvim.nix # your Nixvim HM module
    ./config/noctalia.nix # Noctalia QuickShell wiring (like ddubsos)
  ];
  home = {
    username = lib.mkDefault "your-username";
    homeDirectory = lib.mkDefault "/home/your-username";
    stateVersion = "25.11";
    sessionVariables = {
      GTK_THEME = "Adwaita:dark";
    };
  };

  programs = {
    neovim = {
      enable = false; # No managed by nixvim.nix
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
  };

  gtk = {
    enable = true;
    gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
    };
    gtk4.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
    };
  };

  # Config apps
  home.file.".config/hypr".source = ./config/hypr;
  home.file.".config/waybar".source = ./config/waybar;
  home.file.".config/fastfetch".source = ./config/fastfetch;
  home.file.".config/kitty".source = ./config/kitty;
  home.file.".config/foot".source = ./config/foot;
  home.file.".bashrc-personal".source = ./config/.bashrc-personal;
  home.file.".config/tmux/tmux.conf".source = ./config/tmux.conf;
  home.file.".config/starship.toml".source = ./config/starship.toml;
}
```

</details>

<details>
<summary><code>config/packages.nix</code> – Install Apps</summary>

```nix

{ pkgs, ... }:

{

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

    # Add your packages here
    atop
    bat
    btop
    bottom
    cargo
    clang
    curl
    direnv # needed for zsh plugin and vscode
    fastfetch
    foot
    git
    gcc
    git
    gping
    google-chrome
    htop
    hyfetch
    kitty
    lunarvim # Alternate neovim (lvim)
    luarocks # LUA for nevoim
    ncdu
    nh # Nix Helper
    nixd # nix lsp
    onefetch
    pciutils
    ranger
    ripgrep
    rustup
    starship
    tmux #Terminal mux with hybridd ddubs-tonybtw config
    ugrep
    wget
    yazi
    zig

];

}

```

</details>

<details>
<summary><code>config/fonts.nix</code> – Install Fonts</summary>

```nix
{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      fira-code
      fira-code-symbols
      font-awesome
      hackgen-nf-font
      ibm-plex
      inter
      jetbrains-mono
      material-icons
      maple-mono.NF
      minecraftia
      nerd-fonts.im-writing
      nerd-fonts.blex-mono
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-monochrome-emoji
      powerline-fonts
      roboto
      roboto-mono
      symbola
      terminus_font
    ];
  };
}
```

</details>

## Hyprland keybinds

Default keybinds from <code>config/hypr/hyprland.conf</code> (with <code>$mainMod = SUPER</code>):

| Keys / Modifiers               | Action                                     | Description                                              |
| ------------------------------ | ------------------------------------------ | -------------------------------------------------------- |
| SUPER + Return                 | exec <code>$terminal</code> (foot)         | Open terminal (foot)                                     |
| SUPER + SHIFT + Return         | exec kitty                                 | Open Kitty terminal                                      |
| SUPER + Q                      | killactive                                 | Close focused window                                     |
| SUPER + SHIFT + Q              | exit                                       | Exit Hyprland session                                    |
| SUPER + T                      | exec <code>$fileManager</code> (thunar)    | Launch Thunar file manager                               |
| SUPER + Space                  | togglefloating                             | Toggle floating for focused window                       |
| SUPER + F                      | fullscreen,1                               | Toggle global fullscreen mode                            |
| SUPER + SHIFT + F              | fullscreen                                 | Toggle regular fullscreen                                |
| SUPER + R                      | exec <code>$menu</code> (wofi --show drun) | Application launcher                                     |
| SUPER + S                      | exec <code>$snip</code> (snip)             | Snipping / screenshot tool                               |
| ALT + SHIFT + S                | exec hyprshot…                             | Region screenshot to <code>~/Pictures/Screenshots</code> |
| SUPER + D                      | exec qs … launcher                         | Toggle Noctalia launcher                                 |
| SUPER + M                      | exec qs … notifications                    | Toggle Noctalia notifications                            |
| SUPER + V                      | exec qs … clipboard                        | Open Noctalia clipboard launcher                         |
| SUPER + SHIFT + ,              | exec qs … settings                         | Toggle Noctalia settings                                 |
| SUPER + ALT + L                | exec qs … lockAndSuspend                   | Lock and suspend                                         |
| SUPER + SHIFT + Y              | exec qs … wallpaper                        | Toggle wallpaper module                                  |
| SUPER + X                      | exec qs … sessionMenu                      | Toggle session menu                                      |
| SUPER + C                      | exec qs … controlCenter                    | Toggle control center                                    |
| SUPER + CTRL + R               | exec qs … screenRecorder                   | Toggle screen recorder                                   |
| SUPER + L                      | movefocus l                                | Move focus left                                          |
| SUPER + H                      | movefocus r                                | Move focus right                                         |
| SUPER + K                      | movefocus u                                | Move focus up                                            |
| SUPER + J                      | movefocus d                                | Move focus down                                          |
| SUPER + 1–0                    | workspace 1–10                             | Switch to workspace 1–10                                 |
| SUPER + SHIFT + 1–0            | movetoworkspace 1–10                       | Move focused window to workspace 1–10                    |
| SUPER + mouse scroll down      | workspace e+1                              | Go to next workspace                                     |
| SUPER + mouse scroll up        | workspace e-1                              | Go to previous workspace                                 |
| SUPER + mouse:272 (drag left)  | movewindow                                 | Drag to move window                                      |
| SUPER + mouse:273 (drag right) | resizewindow                               | Drag to resize window                                    |

## Repository layout:


```text path=null start=null
├── CHANGELOG.md
├── config
│   ├── fastfetch
│   │   ├── config.jsonc
│   │   └── nixos.png
│   ├── fonts.nix
│   ├── foot
│   │   └── foot.ini
│   ├── hypr
│   │   ├── animations
│   │   │   ├── 00-default.conf
│   │   │   ├── 01-default-v2.conf
│   │   │   ├── 03-Disable-Animation.conf
│   │   │   ├── END-4.conf
│   │   │   ├── HYDE-default.conf
│   │   │   ├── HYDE-minimal-1.conf
│   │   │   ├── HYDE-minimal-2.conf
│   │   │   ├── HYDE-optimized.conf
│   │   │   ├── HYDE-Vertical.conf
│   │   │   ├── hyprland-default.conf
│   │   │   ├── Mahaveer-me-1.conf
│   │   │   ├── Mahaveer-me-2.conf
│   │   │   ├── ML4W-classic.conf
│   │   │   ├── ML4W-dynamic.conf
│   │   │   ├── ML4W-fast.conf
│   │   │   ├── ML4W-high.conf
│   │   │   ├── ML4W-moving.conf
│   │   │   └── ML4W]-standard.conf
│   │   ├── appearance.conf
│   │   ├── binds.conf
│   │   ├── env.conf
│   │   ├── hyprland.conf
│   │   ├── hyprpaper.conf
│   │   ├── input.conf
│   │   ├── startup.conf
│   │   └── WindowRules.conf
│   ├── images
│   │   ├── ScreenShot-htop-noctalia.png
│   │   ├── ScreenShot-htop-waybar.png
│   │   ├── ScreenShot-Noctalia.png
│   │   └── ScreenShot-waybar.png
│   ├── kitty
│   │   └── kitty.conf
│   ├── nixvim.nix
│   ├── noctalia.nix
│   ├── packages.nix
│   ├── starship.toml
│   ├── tmux.conf
│   ├── vscode.nix
│   ├── wallpapers
│   │   ├── 3d-door.jpg
│   │   ├── a_group_of_wooden_posts_in_water.jpg
│   │   ├── alena-aenami-cloud-sunset.jpg
│   │   ├── alena-aenami-cold.jpg
│   │   ├── alena-aenami-endless.jpg
│   │   ├── alena-aenami-far-from-tomorrow.jpg
│   │   ├── Anime-Lake.png
│   │   ├── Anime-Lanscape.png
│   │   ├── Anime-Purple-eyes.png
│   │   ├── astralbed.png
│   │   ├── beach-ocean-waves-sunset-clouds-scenery-2k-wallpaper.jpg
│   │   ├── bluehour.jpg
│   │   ├── CloudRipple.jpg
│   │   ├── cosmic_blue.jpg
│   │   ├── CuteCat.png
│   │   ├── cyber.jpg
│   │   ├── DT-Mountain-Lake.jpg
│   │   ├── flowers-1.jpg
│   │   ├── Hot-Blue-911.jpg
│   │   ├── lake-dock-fog.jpg
│   │   ├── Lofi-Cafe.jpg
│   │   ├── lofi-Urban-Nightscape.png
│   │   ├── midnight-reflections-moonlit-sea.jpg
│   │   ├── Mily-Way-over-Horse-Head-Rock-New-South-Wales-fog.jpg
│   │   ├── moonlight.jpg
│   │   ├── nordwall3.jpg
│   │   ├── Pastel-lake-boat-on-shore.png
│   │   ├── purple_gasstation_abstract_dark_night.jpg
│   │   ├── Purple-Nightmare.jpg
│   │   ├── River-Moutains-Cherry-Blosums.png
│   │   ├── Seaside-wharf-at-night.avif
│   │   ├── sunrise-horse-head-rock-bermagui-new-south-wales-australia-end-world-172241321.webp
│   │   └── Water-flowing-over-rock.png
│   ├── waybar
│   │   ├── config.jsonc
│   │   └── style.css
│   ├── yazi
│   │   ├── default.nix
│   │   ├── keymap.nix
│   │   ├── theme.nix
│   │   ├── theme.toml
│   │   └── yazi.nix
│   └── zsh.nix
├── configuration.nix
├── flake.lock
├── flake.nix
├── hardware-configuration.nix
├── home.nix
├── install.sh
├── LICENSE
├── modules
│   └── drivers
│       ├── amd-drivers.nix
│       ├── default.nix
│       ├── intel-drivers.nix
│       ├── nvidia-drivers.nix
│       └── vm-guest-services.nix
├── README.md
├── tree.txt
└── WARP.md

```
