{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types mkIf mkMerge;
  inherit (lib.options) mkOption;

  host = config.hostConfig;

  isFish = host.shell == pkgs.fish;
  mkIfFish = mkIf (host.shell == pkgs.fish);

  defaultShell = if isFish then pkgs.bash else host.shell;
in
{
  options.hostConfig = {
    shell =
      with types;
      mkOption {
        type = functionTo shellPackage;
        default = pkgs: pkgs.zsh;
        apply = opt: opt pkgs;
      };
  };

  config = mkMerge [
    {
      users.defaultUserShell = defaultShell;
      programs.direnv.enable = true;
    }

    (mkIfFish {
      programs.fish.enable = true;
      programs.bash.interactiveShellInit =
        # sh
        ''
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING}  && "$LOGNAME" = "wrexes" ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';
    })
  ];
}
