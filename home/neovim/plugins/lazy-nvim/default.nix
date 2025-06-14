{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf throwIfNot;
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.types) mkOptionType;

  types = import ./types.nix { inherit lib; };
  LazySpec = import ./LazySpec.nix { inherit lib types; };

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

  types = lib.types // extraTypes;
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
        type = listOf LazySpec.options;
      };

    package = mkPackageOption pkgs.vimPlugins [ "lazy-nvim" ] { };
  };

  config =
    let
      inherit (lib.trivial) throwIf pipe;
      inherit (lib.strings) getName;
      inherit (lib.lists) forEach concatMap unique;
      inherit (builtins) typeOf filter;
      inherit (lib.attrsets)
        collect
        settAttrByPath
        filterAttrs
        updateManyAttrsByPath
        ;

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

      neovimExtraPackages = [ cfg.package ] ++ unique (flattenDepsTree cfg.plugins);
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
          extraPackages = neovimExtraPackages;
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
