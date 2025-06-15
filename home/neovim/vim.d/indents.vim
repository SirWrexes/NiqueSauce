"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Enable filetype based indentation
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype indent on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Use spaces instead of tabs
"
" I personally think people who prefer tabs are deranged.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set expandtab

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Be smart when using tabs
"
" Just like the last one, a setting for 200 IQ at least people.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set smarttab


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 1 tab == 2 spaces
"
" If you want to set filetype specific shiftwidth, set these
" values in $VIMCONF/<FILETYPE>.vim where FILETYPE is the name
" of the filetype in question.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set shiftwidth=2
set tabstop=2


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Enable auto identation
"
" Developpers are so lazy smh...
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set autoindent


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Galaxy brain indentation
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set smartindent
set nowrap "Disable wrapping lines


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Display some of the whitespace characters
"
" Pairs beautifully with Fira Code
" -> https://github.com/tonsky/FiraCode
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable showing whitespace characters
set list

" Define how they are displayed
"
" See `:h lcs`
set lcs=nbsp:_,tab:\|\ ,trail:~,extends:⇨,precedes:⇦
