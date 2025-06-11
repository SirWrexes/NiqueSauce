{ config, ... }:

{
  programs.lazygit.enable = true;

  programs.lazygit.settings = with config.colorScheme.palette; {
    lightTheme = false;
    activeBorderColor = [
      "#${base0A}"
      "bold"
    ];
    inactiveBorderColor = [ "#${base0B}" ];
    selectedLineBgColor = [ "#${base01}" ];
  };
}
