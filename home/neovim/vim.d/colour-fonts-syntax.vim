"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Enable filetype plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin on


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Enable syntax highlighting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax enable


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Enable 256 colors palette in Gnome Terminal
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => It's just a phase mom!
"
" ... It was not just a phase.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set background=dark


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Extra GUI mode options
"
" Terminal is superior anyway.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('gui_running')
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Use Unix as the standard file type when possible
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set fileformats=unix,dos,mac
