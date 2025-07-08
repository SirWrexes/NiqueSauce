{
  osConfig,
  config,
  pkgs,
  ...
}:

let
  # TODO: Configure theme from nix-color
  deltaOptions = {
    dark = true;
    side-by-side = true;
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
      core.sshCommand = "ssh -i ${osConfig.sops.secrets."ssh/private".path}";
      color.ui = true;
    };
  };

  programs.git.aliases =
    let
      inherit (pkgs.lib) strings;
      inherit (pkgs.lib.meta) getExe getExe';

      pager = "${getExe pkgs.bat}";
      grep = "${getExe pkgs.ripgrep}";
      git = "${getExe pkgs.git}";
      wc = "${getExe' pkgs.coreutils-full "wc"}";

      format = with config.colorScheme.palette; {
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
