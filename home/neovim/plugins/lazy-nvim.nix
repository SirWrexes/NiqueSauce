{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf throwIfNot types;
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;

  mkDescribedEnableOption = name: description: mkEnableOption name // { inherit description; };

  cfg = config.programs.neovim.lazy-nvim;

  extraTypes = {
    required = T: T // { check = (v: v != null); };
    luaPredicate =
      with types;
      mkOptionType {
        name = "Lua.Predicate";
        type = oneOf [
          boolean
          string
          luaInline
        ];
        description = "boolean value or Lua function returning boolean";
        descriptionClass = "conjunction";
      };
  };
in
{
  options.programs.neovim.lazy-nvim = {
    enable = mkDescribedEnableOption "Enable LazyVim plugin manager for NeoVim" ''
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

    luaMultiline = mkDescribedEnableOption "Produce multiline Lua declarations" ''
      By default, this module produces single-line lua declarations.
      This option allows you to change this behaviour and actually produce multiline and indented Lua.

      It makes debugging your configs easier, but minified code can slightly improve performance and storage usage,
      depending on the size of the total accumulated configurations.

      ...and one thing I love about NeoVim is it's amazing speed and responsiveness, don't you agree?
    '';

    lazyByDefault = mkDescribedEnableOption "Make ALL plugins lazy loaded by default." ''
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
        default = null;
        readOnly = true;
        type = nullOr (either boolean luaInline);
        description = ''
          Default `cond` that is assigned to all plugins. You can use it to globally disable plugins in bulk.
          When false, or if the function returns false, then this plugin will not be included in the spec.

          Lazy.nvim ignores extraneous keys on your specs, so you could, for instance, set a common flag
          to check inside them in order to then evaluate some condition to decide if a plugin must
          be activated or not.

          Expected Lua type:
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

    package = mkPackageOption pkgs.vimPlugins [ "lazy-nvim" ] { };
  };

  config =
    let
      toLua = lib.generators.toLua { multiline = cfg.luaMultiline; };

      rootSpec = {
        /**
          Disable automatic plugin updates.
          Plugins will be searched for in the Nix store, as opposed to the usual
          Git flavoured way Lazy.nvim uses.
        */
        checker.enable = false;

        /**
          Prevent Lazy.nvim from installing missing plugins.
          A missing dependcy or plugin *must* be an error since they're
          managed using `nixpkgs`
        */
        install.missing = false;

        lazy = cfg.lazyByDefault;
        cond = cfg.defaultEnablePredicate;
      };
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
        home.packages = [ cfg.package ];

        programs.neovim = {
          extraLuaPackages =
            luapkgs: with luapkgs; [
              luarocks

              # XXX: Keep an eye on https://github.com/nvim-neorocks/rocks.nvim
              # rocks-nvim
            ];
        };

        # I add a bunch of empty lines because it seems the resulting concatenated
        # config can sometimes end up sticking those lua statements directly after another statement,
        # without even adding a space.
        # That happened to me with the colorScheme plugin I set up with nix-colors, I should look into
        # that at some point, maybe a lil' PR could fix it.
        programs.neovim.extraLuaConfig = ''



          vim.opt.rtp:prepend("${cfg.package}")
          require("lazy").setup ${toLua rootSpec}



        '';
      };
}
