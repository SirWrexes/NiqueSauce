{ config, pkgs, ... }:

{
  programs.starship.enable = true;

  programs.starship.settings = {
    directory.style = "bold fg:#f08000";
    
    git_branch.style = "bold fg:#c40f4b";

    git_status = {
      style = "bold fg:#b50000";
      ahead = "⇧";
      behind = "⇩";
      modified = "!";
      "staged_count.enabled" = true;
      "staged_count.style" = "fg:#f08000";
    };

    python = {
      style = "bold fg:#474747";
      prefix = "🐍 ";
    };

    cmd_duration = {
      min_time = 3;
      style = "fg:#474747";
      prefix = "🕙 ";
    };

    character = {
      style_success = "bold fg:#f08000";
      style_failure = "bold red";
      symbol = "->";
      error_symbol = "✗";
      use_symbol_for_status = true;
    };

    jobs = {
      style = "fg:#474747";
      symbol = "❖";
    };

    battery.diabled = true;

    time.style = "italic fg:#3e4e5e";
  };
}
