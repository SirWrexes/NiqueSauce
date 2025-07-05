{ config, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.trivial) flip;
  inherit (config.programs.neovim.lazy-nvim) toLua;
in
{
  config = {
    sources = {
      explorer.layout = {
        preset = "dropdown";
        preview = true;
      };
    };
  };

  keys =
    let
      picker' =
        source: opts:
        mkLuaInline ''
          function() Snacks.picker.${source}(${if opts == null then "" else toLua opts}) end
        '';

      picker = flip picker' null;

      setModeAndLeader =
        { lhs, ... }@key:
        key
        // {
          lhs = "<leader>${lhs}";
          mode = "n";
        };
    in
    map setModeAndLeader [
      {
        lhs = "fhe";
        rhs = picker "help";
        desc = "Vim help";
      }
      {
        lhs = "fhi";
        rhs = picker "highlights";
        desc = "Highlight groups";
      }
      {
        lhs = "f:";
        rhs = picker "commands";
        desc = "Vim commands";
      }
      {
        lhs = "fkm";
        rhs = picker "keymaps";
        desc = "Keymaps";
      }
      {
        lhs = "flz";
        rhs = picker "lazy";
        desc = "Lazy plugin specs";
      }
      {
        lhs = "fe";
        rhs = picker' "explorer" {
          auto_close = true;
          formatters.severity.pos = "left";
          matcher.fuzzy = true;
        };
        desc = "Explorer";
      }
      {
        lhs = "ff";
        rhs = picker "smart";
        desc = "Buffers and files";
      }
      {
        lhs = "fb";
        rhs = picker "buffers";
        desc = "Buffers";
      }
      {
        lhs = "f/";
        rhs = picker "grep";
        desc = "Grep";
      }
      {
        lhs = "fgf";
        rhs = picker "git_files";
        desc = "Git files";
      }
      {
        lhs = "fg/";
        rhs = picker "git_grep";
        desc = "Git grep";
      }
      {
        lhs = "fws";
        rhs = picker "worskapce_symbols";
        desc = "Workspace symbols";
      }
      {
        lhs = "fts";
        rhs = picker "treesitter";
        desc = "Treesitter tags";
      }
      {
        lhs = "fln";
        rhs = picker "lines";
        desc = "Buffer lines";
      }
      {
        lhs = "fcs";
        rhs = picker "colorschemes";
        desc = "Colour schemes";
      }
      {
        lhs = "f?";
        rhs = picker "command_history";
        desc = "Command history";
      }
      {
        lhs = "d";
        rhs = picker "diagnostics_buffer";
        desc = "Buffer diagnostics";
      }
      {
        lhs = "D";
        rhs = picker "diagnostics";
        desc = "Workspace diagnostics";
      }
      {
        lhs = "i";
        rhs = picker "icons";
        desc = "Icons & emojis";
      }
      {
        lhs = "man";
        rhs = picker "man";
        desc = "RTFM time";
      }
      {
        lhs = "gd";
        rhs = picker "lsp_definitions";
        desc = "LSP definitions";
      }
      {
        lhs = "gi";
        rhs = picker "lsp_implementations";
        desc = "LSP implementations";
      }
      {
        lhs = "gr";
        rhs = picker "lsp_references";
        desc = "LSP references";
      }
      {
        lhs = "gs";
        rhs = picker "lsp_symbols";
        desc = "LSP symbols";
      }
      {
        lhs = "gt";
        rhs = picker "lsp_type_definitions";
        desc = "LSP type definitions";
      }
    ];
}
