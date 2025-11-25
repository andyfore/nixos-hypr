# CHANGELOG for Hyprland-btw project

## Started: 11/17/25

## Author: Don Williams (ddubs)

## Inspired by: Tony,btw YouTube Video. (See README.md)

#### Hyprland-btw v0.2.7

- Updated flake
- Moved termainls NIX files to own subdir `config/terminals`
- Moved Editors/IDE NIX files to own subdir `config/editors`
- Added `nvf.nix` Alternate NeoVIM configurator.
  - It's commented out in `home.nix`
- Added:
  - `dino` and `gajim` Jappber/XMPP clients
  - `wl-copy`, `wl-paste`
  - Added `code-runner` plugin to `vscode.nix`

#### Hyprland-btw v0.2.6

- Added `keybinds` rofi search menu

#### Hyprland-btw v0.2.5

- Created desktop file for `kitty-bg`
- Made `kitty-bg` alternmate terminal `SUPERSHIFT+ENTER`

#### Hyprland-btw v0.2.4

- Code cleanup
  - Removed old unused code
  - Moved scripts in home.nix to own dir (config/scripts)
- Added TokyoNight theme (commented out currently)
- Change vscode.nix theme to Nero Hyrland

#### Hyprland-btw v0.2.3

- Code cleanup
  - Moved scripts to own directory `config/scripts`
  - Removed old unused code
- Added TokyoNight theme as option. (commented out )

#### Hyprland-btw v0.2.2

- Added:
  - Kitty
  - Kitty-bg (random background in terminal)
  - Wezterm
  - Alacritty
- Set vscode to Nero Hyprland theme
- Set GTK to Dracula theme
- Set icons to candy-icons
- Re-enabled `symbola` font
- Added legacy rofi menu
- Added rofi menu to edit system files

#### Hyprland-btw v0.2.1

- Added animations directory
- Broke up Hyprland into sourced files
  - `appearnace.conf`
  - `binds.conf`
  - `env.conf`
  - `input.conf`
  - `startup.conf`
  - `WindowRules.conf`

#### Hyprland-btw v0.2.0

- Fixed noctalia not starting on first login after install
- Switched Noctalia to Home Manger config
- Added noctalia systemd service
- DISABLED symbola font in fonts.nix
  - It doesn't download (again)
  - This occurs periodicaly until a new source can be found

#### Hyprland-btw v0.1.3

- Fixed preserving existing users
- Fixed new users get home creation

#### Hyprland-btw v0.1.2

- Fixed username hardcoded to dwilliams
- Fixed hostname not getting updated
- Added check for valid username and prompt to add to enter again
- Addded root password check, prompt to optionally set if not

#### Hyprland-btw v0.1.1

- Merged dev branch to main
- Renamed the last of the tony-nixos to Hyprland-btw
- Fixed install.sh username conflicts causing install failure
- Added sleep to noctalia-shell on first login it doesn't start
- Fixed username not getting set correctly
- Added wallpapers
- Set astralbed.png as hyprpaper default
- Set dock to exclusive by default (no window overlap)
- Enabled wallpaper theming in noctalia-shell as default

## Renamed to `Hyprland-btw`

#### Hyprland-btw-v0.1.0

- Merged dev branch to main
- Renamed project hyprland-btw
- Updated all references
- Add modular GPU drivers (AMD, Intel, NVIDIA) under modules/drivers.
- Add vm.guest-services module to manage QEMU/Spice guest services behind vm.guest-services.enable.
- Wire the drivers stack into flake.nix and move QEMU/Spice services out of configuration.nix.
- Added install.sh as a simple single-host installer
  - Sets:
  - GPU type
  - Hostname
  - Username
  - Timezone
  - Hyprland keymap
  - Console keymap
  - checks for /etc/nixos/hardware-configuration.nix
  - Prompts to copy or regenerate
  - Installs ly login manager
  - Does sudo nixos-rebuild boot --flake
  - Safer than switch

> Note: I.e if you have a LDM it will restart that switching to ly
> Resulting in black screen and you have to re-run the rebuild

- Refreshed `README.md`` with scripted/manual install instructions and drivers documentation.
- Documented a VM-centric GPU profile and how to toggle drivers and VM guest services in configuration.nix.

### Tony-NixOS-v0.0.5

#### Release v0.0.5

- Added modules
- packages.nix
- fonts.nix
- yazi.nix
- Updated README.md
- Summaries for major packages
- Annotated Directory Layout

### Tony-NixOS-v0.0.4

#### Release v0.0.4

- Added flatpak service and added flathub by default
- Added seatd service
- Added gnome keyring
- Added configured vscode

### Tony-NixOS-v0.0.3

#### Release v0.0.3

- Made zsh default shell
  - Added Plugins
  - syntax highlighting
  - autosuggestion
  - git
  - direnv
  - history
  - sudo
  - colored-man-pages
  - command-not-found
  - Added @JustAGuylinux ZSH config
  - Fixed nixos maint aliases for zsh
- Added zoxide shell integration
  - zsh
  - bash
  - fish
- Added EZA shell integration
  - zsh
  - bash
  - fish
- Updated configuration.nix and hardware-configuration.nix NIX formattiung

### Tony-NixOS-v0.0.1

#### Initial Release v0.0.1

- Simple Hyprland Config
- Flake.nix, configuration.nix, hardware.nix
- Noctalia Shell by default
- Simple Waybar alternative
- Ly login manager
- Low memory overhead around 600MB
