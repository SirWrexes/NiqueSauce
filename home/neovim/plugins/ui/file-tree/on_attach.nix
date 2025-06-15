{ lib, name }:

let
  inherit (lib.generators) mkLuaInline;
in
mkLuaInline ''
  function(bufno)
    local api = require "nvim-tree.api"
    local tree, node, config = api.tree, api.node, api.config

    local function delmap(mapping)
      vim.keymap.del("n", mapping, { buffer = bufno })
    end

    local function setmap(mapping, desc, command)
      vim.keymap.set({ "n", "i" }, mapping, command, {
        desc = "${name}: " .. desc,
        buffer = bufno,
        noremap = true,
        silent = true,
        nowait = true,
      })
    end

    config.mappings.default_on_attach(bufno)

    local toDelete = {
      "<2-LeftMouse>", -- Open
      "<2-RightMouse>", -- CD
      "<C-]>", -- CD
      "-", -- CD intro parent
      ">", -- Next sibling
      "<", -- Prev sibling
      "J", -- Last sibling
      "g?", -- Help
      "<C-K>", -- Info
    }

    local toAdd = {
      {
        "?",
        "Help",
        tree.toggle_help,
      },
      {
        "<S-K>",
        "Info",
        node.show_info_popup,
      },
      {
        "cd",
        "CD into selected node",
        tree.change_root_to_node,
      },
      {
        "..",
        "CD into parent node",
        tree.change_root_to_parent,
      },
      {
        "<C-BS>",
        "Collapse all dirs",
        function() tree.collapse_all(true) end,
      },
      {
        "v",
        "Open split (vertical)",
        node.open.vertical,
      },
      {
        "h",
        "Collapse all dirs",
        node.open.horizontal,
      },
    }

    for _, map in ipairs(toDelete) do
      delmap(map)
    end

    for _, map in ipairs(toAdd) do
      setmap(unpack(map))
    end
  end
''
