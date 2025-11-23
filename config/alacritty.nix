{
  pkgs,
  lib,
  ...
}: {
  programs.alacritty = let
    font_family = lib.mkDefault "Maple NF";
  in {
    enable = true;
    settings = {
      font = {
        normal = {
          family = font_family;
          style = "Regular";
        };
        bold = {
          family = font_family;
          style = "Bold";
        };
        italic = {
          family = font_family;
          style = "Italic";
        };
        bold_italic = {
          family = font_family;
          style = "Bold Italic";
        };
        size = 15;
      };
    };
  };
}
