{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.types) mkOptionType;

  toLua = lib.generators.toLua { multiline = cfg.luaMultiline; };
  mkDescribedEnableOption =
    name: extraDescription:
    with lib.types;
    mkOption {
      type = bool;
      default = false;
      description = "Whether to enable ${name}.\n" + extraDescription;
      example = "true";
    };

  cfg = config.programs.neovim.lazy-nvim;

  extraTypes = with lib.types; {
    required = T: T // { check = v: v != null; };
    luaPredicate = either bool luaInline;
    onlyTrue = bool // {
      check = v: v == true;
    };
    onlyFalse = bool // {
      check = v: v == false;
    };
  };

  types = lib.types // extraTypes;

  # Credit goes to Folke for most of the codumentation.
  # Check it out [here](https://lazy.folke.io/spec)!
  # Check out hit awseome projects at http://github.com/folke
  LazySpec =
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
in
{
  options.programs.neovim.lazy-nvim = {
    enable = mkDescribedEnableOption "LazyVim plugin manager for NeoVim" ''
      Important note:
        While configuring this module, you might come accross options that have descriptions
        mentioning Lua function signatures as their accepted type. It means that the option
        must receive a value of type `luaInline.`
        
        Aside from the internal checking that such a value has effectively been produced by
        `lib.generators.mkLuaInline :: a -> luaInline`, there is no way to verify what you
        pass to those options is valid Lua code. It is up to you to make sure that you properly
        wrote your code snippet.

        A minimal amount of knowledge of Lua and event-based / asynchronous programming is required
        to really use Lazy.nvim at its full potential. You can check out my config if you want some
        examples: [TODO: add link]

      `programs.neovim.lazy-vim.luaMultiline` is your friend if you want to check out the generated
      config files—or you could run something like Stylua on them if you wish.

      Lastly, I highly recommend checking out the official docs for the plugin: https://lazy.folke.io/

      Enjoy!
    '';

    luaMultiline = mkDescribedEnableOption "multiline Lua declarations" ''
      By default, this module produces single-line lua declarations.
      This option allows you to change this behaviour and actually produce multiline and indented Lua.

      It makes debugging your configs easier, but minified code can slightly improve performance and storage usage,
      depending on the size of the total accumulated configurations.

      ...and one thing I love about NeoVim is it's amazing speed and responsiveness, don't you agree?
    '';

    lazyByDefault = mkDescribedEnableOption "lazy-loading for ALL plugins by default" ''
      Make all plugins lazy by default. Note that this could end up in some plugins never actually
      activating, or worse even, wrong order of loading which could result in broken dependcy chains.

      Quote from Folke's docs: 
      > Set this to `true` to have all your plugins lazy-loaded by default.
      > Only do this if you know what you are doing, as it can lead to unexpected behavior.

      See https://lazy.folke.io/configuration
    '';

    defaultEnablePredicate =
      with types;
      mkOption {
        readOnly = true;
        type = nullOr luaPredicate;
        default = null;
        description = ''
          Default `cond` that is assigned to all plugins. You can use it to globally disable plugins in bulk.
          When false, or if the function returns false, then this plugin will not be included in the spec.

          Lazy.nvim ignores extraneous keys on your specs, so you could, for instance, set a common flag
          to check inside them in order to then evaluate some condition to decide if a plugin must
          be activated or not.

          Expected luaInline content type:
          ```
          fun(self: LazyPlugin): boolean?
          ```
        '';
        example = ''
          lib.types.mkLuaInline ''''
            function (self)
              if jit.os:find("macos") and self.disableOnMac == true then
                return false
              end
            end
          ''''
        '';
      };

    plugins =
      with types;
      mkOption {
        default = [ ];
        type = listOf LazySpec;
      };

    package = mkPackageOption pkgs.vimPlugins [ "lazy-nvim" ] { };
  };

  config =
    let
      inherit (builtins) filter;
      inherit (lib.strings) getName;
      inherit (lib.trivial) throwIf pipe;
      inherit (lib.lists) concatMap unique;
      inherit (lib.attrsets) filterAttrs updateManyAttrsByPath;

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

      # TODO: (Maybe) Support nested specs, flaten the results.
      finaliseSpec =
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
                  update = _: if dependencies != null then finaliseSpec dependencies else null;
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

      flattenDepsTree = concatMap (
        {
          dependencies,
          package,
          enabled,
          cond,
          ...
        }:
        if enabled != false && cond != false then
          (if package != null then [ package ] else [ ])
          ++ (if dependencies != null then flattenDepsTree dependencies else [ ])
        else
          [ ]
      );
    in
    mkIf
      (
        cfg.enable
        && lib.asserts.assertMsg config.programs.neovim.enable ''
          Hey there ! 󱠡
          I see you're trying to use Lazy.nvim, but it seems NeoVim is not enabled in your home manager config.
          Please enable it and try again.

          󱩖 Put this somewhere in your *home manager* config:
            programs.neovim.enable = true;
        ''
      )
      {
        programs.neovim = {
          extraLuaPackages =
            luapkgs: with luapkgs; [
              luarocks
              # rocks-nvim # XXX: Keep an eye on https://github.com/nvim-neorocks/rocks.nvim
            ];
          extraPackages = [ cfg.package ] ++ unique (flattenDepsTree cfg.plugins);
        };

        # Keep the empty lines above and below the lua code to prevent the statements
        # sticking to other lines during concatenation.
        programs.neovim.extraLuaConfig = ''

          vim.opt.rtp:prepend("${cfg.package}")
          require("lazy").setup(${
            toLua {
              # Disable automatic plugin updates.
              # Plugins will be installed in the Nix store, as opposed to the usual Git flavoured way Lazy.nvim normally uses.
              checker.enable = false;

              # Prevent Lazy.nvim from installing missing plugins.
              # Since we're bypassing the Git installation of plugins, auto-installation shouldn't do anything.
              install.missing = true;

              lazy = cfg.lazyByDefault;
              cond = cfg.defaultEnablePredicate;

              spec = finaliseSpec cfg.plugins;
            }
          })
        '';
      };
}
