{ lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  config.timeout = 5000; # ms

  keys = [
    {
      lhs = "<M-?>";
      rhs = mkLuaInline ''function() Snacks.notifier.show_history() end'';
      desc = "Show history";
    }
  ];
}
