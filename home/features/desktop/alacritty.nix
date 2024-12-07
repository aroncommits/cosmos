{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 5;
          y = 5;
        };
      };
      # colors.normal = {
      #   black = "#f2f2f2";
      #   red = "#a60000";
      #   green = "#006800";
      #   yellow = "#6f5500";
      #   blue = "#0031a9";
      #   magenta = "#721045";
      #   cyan = "#005e8b";
      #   white = "#000000";
      # };
      # colors.bright = {
      #   black = "#c4c4c4";
      #   red = "#a0132f";
      #   green = "#00663f";
      #   yellow = "#7a4f2f";
      #   blue = "#0000b0";
      #   magenta = "#531ab6";
      #   cyan = "#005f5f";
      #   white = "#595959";
      # };
      # colors.cursor = {
      #   cursor = "#000000";
      #   text = "#ffffff";
      # };
      # colors.primary = {
      #   background = "#ffffff";
      #   foreground = "#000000";
      # };
      # colors.selection = {
      #   background = "#bdbdbd";
      #   text = "#000000";
      # };
    };
  };
}
