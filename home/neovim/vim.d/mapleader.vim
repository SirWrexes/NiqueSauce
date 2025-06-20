" Setting `mapleader` in `extraLuaConfig` end up happening *after* Laz.nvim
" spec in generated configs from the `lazy-nvim` module, and that screws up
" a lot of mappings.
" I've tried hacking it away by using `VimEnter` as an event to trigger
" setting up the Lazy spec, but that broke a bunch of plugins.
" Luckily, the viml configs get sources at the top of the lua config.
let mapleader=' '
