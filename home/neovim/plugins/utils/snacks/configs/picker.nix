{ config, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.trivial) flip;
  inherit (config.programs.neovim.lazy-nvim) toLua;
in
{
  config =
    let
      ctrlp =
        mkLuaInline
          # lua
          ''
            {
              preview = true,
              layout = {
                backdrop = false,
                row = 1,
                width = 0.4,
                min_width = 80,
                height = 0.4,
                border = 'none',
                box = 'vertical',
                {
                  win = 'input',
                  height = 1,
                  border = 'rounded',
                  title = '{title} {live} {flags}',
                  title_pos = 'center',
                },
                { win = 'list', border = 'rounded' },
                { win = 'preview', title = '{preview}', border = 'rounded' },
              },
            }
          '';
    in
    {
      sources = rec {
        explorer = {
          auto_close = true;
          layout.preset = "default";
          formatters.severity.pos = "right";
          matcher.fuzzy = true;
        };
        commands.layout = ctrlp;
        command_history.layout = ctrlp;
        keymaps.layout = ctrlp;
        treesitter.layout = {
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
        lhs = "::";
        rhs = picker "commands";
        desc = "Vim commands";
      }
      {
        lhs = ":?";
        rhs = picker "command_history";
        desc = "Command history";
      }
      {
        lhs = ":h";
        rhs = picker "help";
        desc = "Vim help";
      }
      {
        lhs = ":H";
        rhs = picker "highlights";
        desc = "Highlight groups";
      }
      {
        lhs = "fk";
        rhs = picker "keymaps";
        desc = "Keymaps";
      }
      {
        lhs = "e";
        rhs = picker "explorer";
        desc = "Explorer";
      }
      {
        lhs = "<leader>";
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
        lhs = "fs";
        rhs = picker "worskapce_symbols";
        desc = "Workspace symbols";
      }
      {
        lhs = "fts";
        rhs = picker "treesitter";
        desc = "Treesitter tags";
      }
      {
        lhs = "fl";
        rhs = picker "lines";
        desc = "Buffer lines";
      }
      {
        lhs = "fcs";
        rhs = picker "colorschemes";
        desc = "Colour schemes";
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
