{ config, pkgs, ... }:

let
  deltaOptions = {
    dark = true;
    side-by-side = true;
    # TODO: Configure theme from nix-color
  };
in
{
  imports = [ (import ./lazy.nix { inherit deltaOptions; }) ];

  programs.bat.enable = true; # Required for pretty-log
  programs.ripgrep.enable = true; # Required for comit-count

  programs.git = {
    enable = true;
    userName = "Sir Wrexes";
    userEmail = "ludofernandez@msn.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.sshCommand = "ssh -i ~/.ssh/id_ed25519";
    };
    color.ui = true;
  };

  programs.git.aliases =
    with config.colorScheme.palette;
    let
      inherit (pkgs.lib) strings;

      pager = "${pkgs.bat}/bin/bat"; # TODO: Make an option
      grep = "${pkgs.ripgrep}/bin/rg"; # TODO: Make an option
      git = "${pkgs.git}/bin/git";
      wc = "${pkgs.coreutils-full}/bin/wc";

      format = {
        options =
          format:
          strings.concatStringsSep " " [
            "--color"
            "--abbrev-commit"
            "--decorate=auto"
            ''--pretty=format:"${format}"''
          ];
        complete = "%w(72,2,5)%C(ul #${base0A})%h%C(noul):%Creset %C(bold)%s%Creset%n%C(#${base0A})└%C(dim #${base0A})%an, %cr%+gD%Creset";
        short = "%w(72,2,5)%C(ul #${base0A})%h%C(noul):%Creset %C(bold)%s%Creset";
      };
    in
    {
      plog = "pretty-log";
      pretty-log = "!${git} log --graph ${format.options format.complete} | ${pager} --style=grid";

      splog = "short-pretty-log";
      short-pretty-log = "!${git} log ${format.options format.short} | ${pager} --style=grid,numbers";

      cc = "commit-count";
      commit-count = "!${git} plog | ${grep} -E '^\\*' | ${wc} -l";
    };

  programs.git.delta = {
    enable = true;
    options = deltaOptions;
  };
}
