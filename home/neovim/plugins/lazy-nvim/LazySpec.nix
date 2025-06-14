let
  # Credit goes to Folke for most of the codumentation.
  # Check it out [here](https://lazy.folke.io/spec)!
  # Check out hit awseome projects at http://github.com/folke
  LazySpec.options =
    with types;
    submodule rec {
      options = {
        name = mkOption {
          type = nullOr str;
          default = null;
          description = "Display name for the plugin. If not provided, `lib.meta.getName` will be used on the plugin's package.";
        };
        package = mkPackageOption pkgs.vimPlugins "plugin" {
          default = null;
          extraDescription = "Nix package for the plugin.";
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
          type = nullOr luaInline;
          default = null;
          description = ''
            Init functions are always executed during startup.
            Mostly useful for setting vim.g.* configuration used by Vim plugins startup

            Expected luaInline content type:
            ```
            fun(LazyPlugin)
            ```
          '';
        };
        opts = mkOption {
          type = nullOr luaPredicate;
          default = null;
          description = ''
            `opts` should be a table (will be merged with parent specs), return a table (replaces parent specs) or should change a table.
            The table will be passed to the Plugin.config() function. Setting this value will imply Plugin.config()

            Expected luaInline content type:
            ```
            fun(self: LazyPlugin, opts: table)
            ```
          '';
        };
        config = mkOption {
          type = nullOr (either luaInline onlyTrue);
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

                BAD
              ```
              {
                package = pkgs.vimPlugins.lazydev-nvim;
                config = mkLuaInline ''''
                  function() require("todo-comments").setup({}) end
                '''';
              }
              ```

            Expected luaInline content type:
            ```
            fun(self: LazyPlugin, opts: table)
            ```
          '';
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
            luaInline
            str
            bool
          ]);
          default = null;
          description = ''
            Build is executed when a plugin is installed or updated.
            See [Building](https://lazy.folke.io/developers#building) for more information.

            Expected luaInline content type:
            ```
            fun(LazyPlugin)
            ```
          '';
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
            luaInline
            (submodule {
              event = either [
                # TODO: Create NeoVim event enum
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

            Expected luaInline content type: 
            ```
            fun(self: LazyPlugin, event: string[]): string[]
            ```
          '';
        };
        cmd = mkOption {
          type = nullOr (oneOf [
            str
            (listOf str)
            luaInline
          ]);
          default = null;
          description = ''
            Lazy-load on command.

            Expected luaInline content type: 
            ```
            fun(self: LazyPlugin, cmd: string[]): string[]
            ```
          '';
        };
        ft = mkOption {
          type = nullOr (oneOf [
            str
            (listOf str)
            luaInline
          ]);
          default = null;
          description = ''
            Lazy-load on filetype.

            Expected luaInline content type:
            ```
            fun(self:LazyPlugin, ft: string[]):string[]
            ```
          '';
        };
        key = mkOption {
          type = nullOr (oneOf [
            str
            (listOf str)
            luaInline # TODO: Make KeySpec and corresponding Lua generator
          ]);
          default = null;
          description = ''
            Set the key mappings for your plugin.
            Using this option instead of just having your bindings somewhere in your NeoVim config will enable lazy-loading the plugin on using them.
          '';
        };
      };
    };

  ensureHasPackageOrDir =
    {
      package ? null,
      dir ? null,
      ...
    }@plugin:
    throwIf (package == null && dir == null) ''
      No package or dir attribute provided.
      Spec: ${toString plugin}
    '' plugin;

  LazySpec.fromPlugins =
    plugins:
    map
      (
        {
          dir ? null,
          package ? null,
          name ? null,
          dependencies ? null,
          ...
        }@plugin:
        pipe plugin [
          ensureHasPackageOrDir
          (updateManyAttrsByPath [
            {
              path = [ "name" ];
              update =
                _:
                if name != null then
                  name
                else if package != null then
                  getName package
                else
                  baseNameOf dir;
            }
            {
              path = [ "dir" ];
              update = _: if dir != null then dir else package;
            }
            {
              path = [ "package" ];
              update = _: null;
            }
            {
              path = [ "dependencies" ];
              update = _: if dependencies != null then LazySpec.fromPlugins dependencies else null;
            }
          ])
          (filterAttrs (n: v: v != null))
        ]
      )
      (
        filter (
          {
            enabled ? false,
            cond ? false,
            ...
          }:
          (enabled != false && cond != false)
        ) plugins
      );
in
LazySpec
