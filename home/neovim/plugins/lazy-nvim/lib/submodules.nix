{ lib }:

# Credit goes to Folke for most of the documentation.
# Check it out [here](https://lazy.folke.io/spec).
# Check out his awseome projects on [Github](http://github.com/folke)!
let
  inherit (lib.options) mkOption;

  types = import ./types.nix { inherit lib; };
in
rec {
  LazyKey =
    with types;
    submodule {
      options = {
        lhs = mkOption {
          type = str;
          description = "Key of sequence of key to map to";
        };
        rhs = mkOption {
          type = nullOr (either str luaSnippet);
          default = null;
          description = "The action to perform";
          apply = readLuaSnippet;
        };
        mode = mkOption {
          type = nullOr (either str (listOf str));
          default = "n";
          description = "Vim mode for this mapping";
          example = literalExpression ''["n" "i"]'';
        };
        desc = mkOption {
          type = nullOr str;
          default = null;
          description = "Mapping description";
        };
        silent = mkOption {
          type = nullOr bool;
          default = true;
          description = "Don't show the executed command in NeoVim's command line.";
        };
        noremap = mkOption {
          type = nullOr bool;
          default = true;
          description = "Disable recursive mapping (see https://neovim.io/doc/user/map.html#recursive_mapping).";
        };
      };
    };

  LazySpec =
    with types;
    submodule {
      options = {
        name = mkOption {
          type = nullOr str;
          default = null;
          description = "Display name for the plugin. If not provided, `lib.meta.getName` will be used on the plugin's package.";
        };
        dir = mkOption {
          type = nullOr (either path str);
          default = null;
          description = ''
            Local directory for the plugin
          '';
        };
        package = mkOption {
          type = nullOr package;
          default = null;
          description = "Nix package for the plugin.";
        };
        dependencies = mkOption {
          type = nullOr (listOf LazySpec);
          default = null;
          description = ''
            Dependencies for this plugin.
            Setting them here instead of at the root of the will ensure they are loaded before starting this plugin.
          '';
        };
        enabled = mkOption {
          type = nullOr luaPredicate;
          default = null;
          description = ''
            When false, or if the function returns false, then this plugin will not be included in the spec.

            Expected lua type:
            ```
            fun(): boolean?
            ```
          '';
          apply = readLuaSnippet;
        };
        cond = mkOption {
          type = nullOr luaPredicate;
          default = null;
          description = ''
            Behaves the same as `enabled`, but won't uninstall the plugin when the condition is false.
            Useful to disable some plugins in vscode, or firenvim for example.

            Expected lua type:
            ```
            fun(): boolean?
            ```
          '';
          apply = readLuaSnippet;
        };
        priority = mkOption {
          type = nullOr number;
          default = null;
          description = ''
            Only useful for *start* plugins (`lazy = false`) to force loading certain plugins first.
            Default priority is 50. It's recommended to set this to a high number for colorschemes.
          '';
        };
        init = mkOption {
          type = nullOr luaSnippet;
          default = null;
          description = ''
            Init functions are always executed during startup.
            Mostly useful for setting vim.g.* configuration used by Vim plugins startup

            Expected luaSnippet content type:
            ```
            fun(LazyPlugin)
            ```
          '';
          apply = readLuaSnippet;
        };
        opts = mkOption {
          type = nullOr (either attrs luaSnippet);
          default = null;
          description = ''
            `opts` should be a table (will be merged with parent specs), return a table (replaces parent specs) or should change a table.
            The table will be passed to the Plugin.config() function. Setting this value will imply Plugin.config()

            Expected luaSnippet content type:
            ```
            fun(self: LazyPlugin, opts: table)
            ```
          '';
          apply = readLuaSnippet;
        };
        config = mkOption {
          type = nullOr (either luaSnippet onlyTrue);
          default = null;
          description = ''
            Config is executed when the plugin loads.
            The default implementation will automatically run require(MAIN).setup(opts) if `opts` is defined or `config = true` is set.
            Lazy uses several heuristics to determine the plugin's MAIN module automatically based on the plugin's name.

            Note:
              Always prefer using `opts` over `config`. `config` is almost never necessary.

              󱩖  GOOD
              ```
              { package = pkgs.vimPlugins.lazydev-nvim; opts = { ... }; },
              ```

                BAD (most of the times)
              ```
              {
                package = pkgs.vimPlugins.lazydev-nvim;
                config = mkLuaInline ''''
                  function() require("todo-comments").setup({}) end
                '''';
              }
              ```

            Expected luaSnippet content type:
            ```
            fun(self: LazyPlugin, opts: table)
            ```
          '';
          apply = readLuaSnippet;
        };
        main = mkOption {
          type = nullOr str;
          default = null;
          description = ''
            You can specify the main module to use for config() and opts(), in case it can not be determined automatically.
            See config().
          '';
        };
        build = mkOption {
          type = nullOr (oneOf [
            luaSnippet
            str
            bool
          ]);
          default = null;
          description = ''
            Build is executed when a plugin is installed or updated.
            See [Building](https://lazy.folke.io/developers#building) for more information.

            Expected luaSnippet content type:
            ```
            fun(self: LazyPlugin)
            ```
          '';
          apply = readLuaSnippet;
        };
        lazy = mkOption {
          type = nullOr bool;
          default = null;
          description = ''
            When true, the plugin will only be loaded when needed.
            Lazy-loaded plugins are automatically loaded when their Lua modules are required, or when one of the lazy-loading handlers triggers.
          '';
        };
        event = mkOption {
          type = nullOr (oneOf [
            str
            (listOf str)
            luaSnippet
            (submodule {
              event = either [
                # TODO: Create NeoVim event enum
                # ... Actually, maybe not.
                str
                (listOf str)
              ];
              pattern = either [
                str
                (listOf str)
              ];
            })
          ]);
          default = null;
          description = ''
            Lazy-load on event. Events can be specified with or without paramters (e.g. `BufEnter` or `BufEnter *.lua`).

            Expected luaSnippet content type: 
            ```
            fun(self: LazyPlugin, event: string[]): string[]
            ```
          '';
          apply = readLuaSnippet;
        };
        cmd = mkOption {
          type = nullOr (oneOf [
            str
            (listOf str)
            luaSnippet
          ]);
          default = null;
          description = ''
            Lazy-load on command.

            Expected luaSnippet content type: 
            ```
            fun(self: LazyPlugin, cmd: string[]): string[]
            ```
          '';
          apply = readLuaSnippet;
        };
        ft = mkOption {
          type = nullOr (oneOf [
            str
            (listOf str)
            luaSnippet
          ]);
          default = null;
          description = ''
            Lazy-load on filetype.

            Expected luaSnippet content type:
            ```
            fun(self:LazyPlugin, ft: string[]):string[]
            ```
          '';
          apply = readLuaSnippet;
        };
        keys = mkOption {
          type = nullOr (either luaSnippet (listOf (either str LazyKey)));
          default = null;
          description = ''
            Set the key mappings for your plugin.
            Using this option instead of just having your bindings somewhere in your NeoVim config will enable lazy-loading the plugin on using them.
          '';
          apply = readLuaSnippet;
        };
      };
    };
}
