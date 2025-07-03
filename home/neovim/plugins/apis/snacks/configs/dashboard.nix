{ lib, pkgs, ... }:

let
  inherit (builtins) map;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.meta) getExe;
  inherit (lib.trivial) flip;

  toLua = lib.generators.toLua { };

  commits = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/ngerakines/commitment/refs/heads/main/commit_messages.txt";
    sha256 = "sha256:0sc0r6kl3qdh7a3vca313w8qbwg5hsnrq5c904w4rgk6lsqmk19h";
  };

  mkSections = {
    repo = rec {
      setDefaults =
        section:
        {
          section = "terminal";
          pane = 2;
          indent = 3;
          padding = 2;
        }
        // section;

      toLuaSections = sections: toLua (map setDefaults sections);

      __functor =
        _: sections:
        mkLuaInline
          # lua
          ''
            function()
              local enabled = Snacks.git.get_root() ~= nil
              local function setEnabled(elem)
                return vim.tbl_extend('force', elem, { enabled = enabled })
              end

              return vim.tbl_map(
                setEnabled,
                ${toLuaSections sections}
              )
            end
          '';
    };
  };
in
{
  preset = {
    header = ''
             ⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⢠⣖⣿⢐⡆⠀⠀⠀⠀⠀⠀⠀⡀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⢠⢻⡾⡿⡳⡹⣀⢀⠀⢀⠤⢆⣶⡫⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⣯⣻⡫⡯⣳⢝⡮⣫⢯⡳⣻⢸⣿⣭⢽⡇⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⢸⢯⡺⣭⢙⢮⡳⣝⢮⡳⠝⢮⢏⡯⣚⣽⡇⠀⠀⠀⠀⠀⠀⠀⠀
      ⣿⣿⣿⣿⣇⣀⣼⡕⠕⢕⣇⣏⠉⠀⡯⣺⢝⣾⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠈⣻⣿⣿⣿⣿⡻⠷⡲⢾⢿⣿⣷⣶⣿⣿⣷⣷⣶⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⡿⡋⠁⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠈⠙⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠟⠋⠁⠀⣠⣴⣾⣟⣥⣤⣤⣄
      ⠀⠀⠀⠀⠀⠀⡐⣯⣿⣽⡯⣗⢖⣆⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⡟⠉
      ⠀⠀⠀⠀⠀⣔⢽⡩⣿⡏⡾⣕⢯⢮⣣⠀⠀⢐⢧⢿⣿⣿⣿⣿⣻⠀⠀
      ⠀⢀⠀⡀⠀⣗⢽⡪⠓⡸⣝⢮⠇⣕⣗⠀⠀⠱⡹⡽⣻⡻⡮⣟⠯⠀⠀
      ⠨⢒⠂⡂⠨⡺⠕⠯⢐⠯⡺⣝⢑⢕⠠⢰⠨⢄⠨⡹⡚⡮⡳⡱⠁⠀⠀
      ⠀⡑⢵⠀⡂⠠⠁⠂⠀⢂⠂⢂⣖⢐⠐⡠⡲⠠⢐⢅⠇⡎⠢⠁⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠈⠀⠐⠈⠀⠀⠀
    '';

    keys = [
      (mkLuaInline
        # lua
        ''
          function()
            return {
                icon = " ",
                title = "Browse repo",
                key = "b",
                action = ":lua Snacks.gitbrowse()",
                enabled = Snacks.git.get_root() ~= nil,
              }
          end
        ''
      )
      {
        icon = " ";
        key = "r";
        desc = "Recent Files";
        action = ":lua Snacks.dashboard.pick('oldfiles')";
      }
      {
        icon = " ";
        key = "f";
        desc = "Find File";
        action = ":lua Snacks.dashboard.pick('files')";
      }
      {
        icon = " ";
        key = "n";
        desc = "New File";
        action = ":ene | startinsert";
      }
      {
        icon = " ";
        key = "g";
        desc = "Find Text";
        action = ":lua Snacks.dashboard.pick('live_grep')";
      }
      {
        icon = " ";
        key = "c";
        desc = "Config";
        action = ":lua Snacks.dashboard.pick('files'; {cwd = '~/.nixos'})";
      }
      {
        icon = " ";
        key = "s";
        desc = "Restore Session";
        section = "session";
      }
      {
        icon = " ";
        key = "q";
        desc = "Quit";
        action = ":qa";
      }
    ];
  };

  sections = [
    { section = "header"; }
    (mkLuaInline
      # lua
      ''
        function()
          local i = 0
          local lines = {}

          for line in io.lines(${toLua commits}) do
            i = i + 1
            lines[i] = line
          end

          local message = lines[math.random(1, i)]
          local unquoted = message:gsub('^"', ""):gsub('"$', "")
          local commit = ('git commit -m "%s"'):format(unquoted)

          return {
            text = { commit, hl = "SpellRare" },
            padding = 3,
            height = 2,
            align = center,
          }
        end
      ''
    )
    {
      title = "Projects";
      section = "projects";
      icon = " ";
      indent = 2;
      padding = 2;
    }
    {
      section = "keys";
      padding = 2;
    }
    (mkSections.repo [
      {
        icon = " ";
        title = "Notifications";
        cmd = ''echo -e "$(${getExe pkgs.gh-notify} -s -a -n5)"'';
        action = mkLuaInline ''
          function()
              vim.ui.open("https://github.com/notifications")
          end
        '';
        key = "n";
        height = 5;
        enabled = true;
        # width = 75 * 2;
      }
      {
        icon = " ";
        title = "Status";
        cmd = "git --no-pager diff --stat -B -M -C";
      }
      {
        title = "Graph";
        icon = " ";
        cmd = ''echo -e "$(${getExe pkgs.git-graph} --style round --color always --wrap 50 0 8 -f 'oneline')"'';
        height = 35;
      }
    ])
    { section = "startup"; }
  ];
}
