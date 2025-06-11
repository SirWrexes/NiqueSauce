{ deltaOptions }:

{ config, pkgs, ... }:

{
  programs.lazygit.enable = true;

  programs.lazygit.settings = {
    gui = {
      nerdFontsVersion = "3";

      theme = with config.colorScheme.palette; {
        lightTheme = false;
        activeBorderColor = [
          "#${base08}"
          "bold"
        ];
        inactiveBorderColor = [ "#${base09}" ];
        selectedLineBgColor = [ "#${base01}" ];
        optionsTextColor = [ "#${base0C}" ];
        unstagedChangesColor = [
          "#${base0A}"
          "bold"
        ];
      };

      spinner.frames = [
        ""
        ""
        ""
        ""
        ""
        ""
      ];
    };

    git = {
      branchLogCmd = "git pretty-log";
      allBranchesLogCmds = [ "git pretty-log" ];
      parseEmoji = true;
      paging.pager =
        let
          inherit (pkgs) writeTextFile;
          inherit (pkgs.lib.attrsets) filterAttrs;
          inherit (pkgs.lib.meta) getExe;

          toINI = pkgs.lib.generators.toINI { };

          config = writeTextFile {
            name = "config";
            text = toINI { delta = filterAttrs (name: value: name != "side-by-side") deltaOptions; };
          };
        in
        "${getExe pkgs.delta} --paging=never --config=${config}";
    };
  };
}
