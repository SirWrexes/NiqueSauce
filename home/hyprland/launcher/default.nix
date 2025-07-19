{
  config,
  lib,
  ...
}:

let
  inherit (lib.strings) concatStringsSep;
in
{
  programs.tofi.enable = true;

  # TODO: Configure colours with nix-colors
  # For options see https://github.com/philj56/tofi/blob/master/doc/config
  programs.tofi.settings = {
    # Fonts
    font = "FiraCode Nerd Font";
    font-features = concatStringsSep ", " [
      "liga 1" # enable ligatures
      "scmp, c2sc" # all small caps
    ];

    # Window
    width = "30%";
    height = "30%";

    # Behaviour
    text-cursor = true;
    fuzzy-match = true;
  };

  # Ensure that newly installed desktop apps appear in drun mode
  home.activation.flush-tofi-drun-cache =
    lib.hm.dag.entryAfter [ "writeBoundary" ]
      # sh
      ''
        tofi_cache=${config.xdg.cacheHome}/tofi-drun
        [[ -f "$tofi_cache" ]] && rm "$tofi_cache"
      '';
}
