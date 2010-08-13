" vim: set et sw=2 sts=2 fdm=marker fdl=0:
"
" Command quick reference {{{
" vis.vim:
"   B <ex command> - execute the ex command over the visual block.  Nice for
"                    doing search/replace.
" surround:
"   normal mode:
"     ds - delete surrounding chars
"     cs - change/insert surrounding chars
"   visual mode:
"     s - change/insert surrounding chars
"     S - change/insert surrounding chars, always on seperate lines
"   insert mode:
"     <C-G> s - change/insert surrounding chars
" Align/AlignMaps:
"   \adec - align C declarations
"   \acom - align comments
"   \afnc - align ansi-style C function input arguments
"   \Htd  - align html tables
" NERD commenter:
"   \cs - apply 'sexy' comment to line(s)
"   \c<space> - toggle commenting on line(s)
"   \cc - comment block as a whole (doesnt obey space_delim)
"   \ci - comment individually
"   \cu - uncomment individually
" modelines inserter:
"   \im - insert modelines based on current settings
" Line highlighter:
"   \hcli - enable highlighting of the current line
"   \hcls - disable highlighting of the current line
" winmanager (if enabled):
"   ^W^T - toggle
"   ^W^F - top left window
"   ^W^B - bottom left window
"   ^N (in the file explorer window) - toggle file explorer / tag list
" taglist (if not using winmanager):
"   F8 - toggle
" GetLatestVimScripts:
"   :GLVS - Checks to see if any vim scripts have new versions available,
"           and if so, downloads them (and installs in some cases).
" hilink:
"   \hlt - Show information on the highlight group(s) for the text under
"          the cursor.
" parenquote:
"   \( - parenthesize with ()
"   \{ - parenthesize with {}
"   \[ - parenthesize with []
"   \< - parenthesize with <>
"   \' - quote with ''
"   \" - quote with ""
"   \` - quote with ``
" VIM core:
"   K - look up current word via 'man' (by default)
"   ^X ^O - Omni completion
"   * - search for teh current word in the document
"   % - jump between begin/end of blocks
"   ggqgG - reformat entire file
"   gwap - reformat paragraph
"   gg=G - reindent entire file

" Common indentation setups
"   No hard tabs, 2 space indent: set sw=2 sts=2 et
"   No hard tabs, 4 space indent: set sw=4 sts=4 et
"   All hard tabs, 8 space tabstops: set ts=8 sw=8 sts=0 noet
"   Hard tabs for indentation, 4 space tabstops: set ts=4 sw=4 sts=0 noet
"   Horrendous, 4 space indent, 8 space tabstops, hard tabs:
"      set ts=8 sw=4 sts=4 noet
" }}}

if v:version < 600
  echo 'ERROR: Vim version too old.  Upgrade to Vim 6.0 or later.'
  finish
endif


" Ugh, behave mswin makes GVim act like other windows applications, not like
" Vim.  This behavior is not what I expect.
if has('win32')
  source $VIMRUNTIME/mswin.vim
endif
behave xterm

" Functions {{{
fun! Print(...)
  let l:colo = g:colors_name
  let l:printcolo = a:0 == 1 ? a:1 : 'print_bw'
  let l:bg = &background

  exe 'colo ' . l:printcolo
  let &background = 'light'
  ha
  exe 'colo ' . l:colo
  let &background = l:bg
endfun

fun! <SID>Max(a, b)
  if a:a >= a:b
    return a:a
  else
    return a:b
  endif
endfun

" Display the current tag if available, or nothing
" Used by the statusline
fun! StatusLine_Tlist_Info()
  if exists('g:loaded_taglist') &&
        \ g:loaded_taglist == 'available'
    return Tlist_Get_Tagname_By_Line()
  else
    return ''
  endif
endfun

fun! StatusLine_FileName()
  try
    let fn = pathshorten(expand('%f')) . ' '
  catch
    let fn = expand('%f') . ' '
  endtry
  return fn
endfun
" }}}

" Keymaps and Commands {{{
let mapleader = ","

map <leader>del :g/^\s*$/d<CR>         ' Delete Empty Lines
map <leader>ddql :%s/^>\s*>.*//g<CR>   ' Delete Double Quoted Lines
map <leader>ddr :s/\.\+\s*/. /g<CR>    ' Delete Dot Runs
map <leader>dsr :s/\s\s\+/ /g<CR>      ' Delete Space Runs
map <leader>dtw :%s/\s\+$//g<CR>       ' Delete Trailing Whitespace

" Reformat paragraph
noremap <Leader>gp gqap

" Reformat everything
noremap <Leader>gq gggqG

" Reindent everything
noremap <Leader>= gg=G

" Select everything
noremap <Leader>gg ggVG

" Mappings to edit/reload the .vimrc
if ! exists('$MYVIMRC')
  if has('win32')
    let $MYVIMRC = $HOME . '/_vimrc'
  else
    let $MYVIMRC = $HOME . '/.vimrc'
  endif
endif
if ! exists('$MYVIMRUNTIME')
  if has('win32')
    let $MYVIMRUNTIME = $HOME . '/_vim'
  else
    let $MYVIMRUNTIME = $HOME . '/.vim'
  endif
endif
nmap <silent> <leader>v :e $MYVIMRC<CR>

" quickfix things
nmap <Leader>cwc :cclose<CR>
nmap <Leader>cwo :botright copen 5<CR><C-w>p
nmap <Leader>ccn :cnext<CR>

" Arrow keys behavior
nmap <silent> <Up> :wincmd k<CR>
nmap <silent> <Down> :wincmd j<CR>
nmap <silent> <Left> :wincmd h<CR>
nmap <silent> <Right> :wincmd l<CR>

" Plugins
nmap <leader>im :Modeliner<CR>

nnoremap <Leader>s :TlistToggle<Enter>
nnoremap <Leader>S :TlistShowPrototype<Enter>

nnoremap <Leader>f :NERDTreeToggle<Enter>
nnoremap <Leader>F :NERDTreeFind<Enter>

" Mouse {{{
if has('mouse')
  set mouse=a
  if has('unix') &&
        \ ! has('gui_running')
    if &term == 'xterm'
      set ttymouse=xterm2
    else
      set ttymouse=xterm
    endif
  endif
endif

" Line numbering
if v:version >= 700
  set number
endif

" When selecting with the mouse, copy to clipboard on release.
vnoremap <LeftRelease> '+y<LeftRelease>gv
vnoremap <RightRelease> '+y<RightRelease>gv

" Mouse scroll wheel mappings only work in X11 and terminals
if &ttymouse != '' ||
      \ (has('gui_running') && has('unix'))
  map <MouseDown> 3
  map <MouseUp> 3

  " meta (alt)+scrollwheel = scroll one line at a time
  map <M-MouseDown> 
  map <M-MouseUp> 

  " ctrl+scrollwheel = scroll half a page
  map <C-MouseDown> 
  map <C-MouseUp> 

  " shift+scrollwheel = unmapped
  " unmap <S-MouseDown>
  " unmap <S-MouseUp>
endif
" }}}

" Execute an appropriate interpreter for the current file
" If there is no #! line at the top of the file, it will
" fall back to g:interp_<filetype>, and further to <filetype>.
fun! RunInterp()
  let l:interp = ''
  let line = getline(1)

  if line =~ '^#\!'
    let l:interp = strpart(line, 2)
  else
    if exists('g:interp_' . &filetype)
      let l:interp = g:interp_{&filetype}
    else
      let l_interp = &filetype
    endif
  endif
  if l:interp != ''
    exe '! ' . l:interp . ' %'
  endif
endfun
nnoremap <silent> <F9> :call RunInterp()<CR>
com! -complete=command Interp call RunInterp()

com! DiffOrig bel new | set bt=nofile | r # | 0d_ | diffthis
      \ | wincmd p | diffthis
" }}}

" Fonts {{{
let g:fontsize = "11"
if has("gui_running")
  if has("gui_gtk2")
    let g:fontface = "DejaVu Sans Mono"
    let &guifont = g:fontface." ".g:fontsize
  elseif has('macunix') && has('gui')
    let g:fontface = "Monaco"
    let &guifont = g:fontface." ".g:fontsize
  elseif has('gui_win32')
    let g:fontface = "Consolas"
    let &guifont = g:fontface.":h".g:fontsize."cANSI"
  endif
endif
" }}}

" Indentation {{{
set smarttab

" Disable insertion of tabs as compression / indentation
set expandtab

" How many spaces a hard tab in the file is shown as, and how many
" spaces are replaced with one hard tab when using sts != ts and noet.
set tabstop=8

" Indentation width (affects indentation plugins, indent based
" folding, etc, and when smarttab is on, is used instead of ts/sts
" for the indentation at beginning of line.
set shiftwidth=4

" Number of spaces that the tab key counts for when editing
" Only really useful if different from ts, or if using et.
" When 0, it is disabled.
set softtabstop=4

set autoindent
set nosmartindent

" Set the C indenting the way I like it
set cinoptions=>s,e0,n0,f0,{0,}0,^0,:s,=s,l0,g0,hs,ps,ts,+s,c3,C0,(0,us,\U0,w0,m0,j0,)20,*30
set cinkeys=0{,0},0),:,0#,!^F,o,O,e
" }}}

" Settings {{{

filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
filetype plugin indent on

set secure
" Not vi compatible, we want spiffy Vim features, please.
if &compatible
    set nocompatible
endif
set nodigraph

" Reliant upon securemodelines.vim
set modelines=5
set nomodeline

" Fast terminal, bump sidescroll to 1
set sidescroll=1

" Show 2 rows/cols of context when scrolling
set scrolloff=2
set sidescrolloff=2

" The prompt to save changes when switching buffers is incredibly annoying
" when doing development.  An alternative is to set autowrite, but one could
" easily lose old changes that way.  I like to write when I'm explicitly ready
" to do so.
set hidden
" set path=.

" Allow setting window title for screen
if &term =~ '^screen'
  set t_ts=k
  set t_fs=\
endif

" Nice window title
set title
if has('title') && (has('gui_running') || &title)
  set titlestring=
  set titlestring+=%f                    " file name
  set titlestring+=%(\ %h%m%r%w%)        " flags
  set titlestring+=\ -\ %{v:progname}    " program name
endif
set titleold=

set ttyfast
set ttybuiltin
set lazyredraw

" Windowing Options {{{
" Windows that need winfixheight:
"   [ ] minibufexpl
" Windows that need winfixwidth:
"   [ ] Taglist
"   [ ] Bufexplorer
"   [x] VTreeExplorer
" Also set winminheight and winminwidth possibly, as the fix height and fix
" width options are not always obeyed (if running out of room), while the
" minimums are hard minimums. (done for vtreeexplorer)

" Window resize behavior when splitting
set noequalalways
set eadirection=both

set splitright
set splitbelow
" }}}

" No annoying beeps
set novisualbell
set noerrorbells
set vb t_vb=

" Default folding settings
if has('folding')
  set foldenable
  set foldcolumn=0
  set foldminlines=3
  set foldmethod=indent
  set foldlevel=5
endif

" Cscope
if has("cscope")
  set csto=0
  set cst
  set nocsverb
  " add any database in current directory
  if filereadable("cscope.out")
    cs add cscope.out
    " else add database pointed to by environment
  elseif $CSCOPE_DB != ""
    cs add $CSCOPE_DB
  endif
  set csverb
endif

" Tags search path
set tags=./tags,tags,$PWD/tags


" Nifty completion menu
set wildmenu
set wildignore+=*.o,*~
" set wildmode=longest:full,full
set wildmode=longest:full

set suffixes+=.in,.a,.lo,.o,.moc,.la,.closure

set whichwrap=<,>,h,l,[,]
set ruler
set showcmd
set textwidth=0

" Write backup files and do not remove them after exit.
set backup
set writebackup
" Rename the file to the backup when possible.
set backupcopy=auto
" Don't store all the backup and swap files in the current working dirctory.
if has("win32")
  let &backupdir = './_vimtmp,' . $TEMP . ',c:/tmp,c:/temp'
else
  let &backupdir = './.vimtmp,' . $HOME . '/.vim/tmp,/var/tmp,/tmp'
endif
let &directory = &backupdir

set isk+=_,$,@,%,#,-
set shortmess=atItToO

" Test display
"  lastline  When included, as much as possible of the last line
"            in a window will be displayed.  When not included, a
"            last line that doesn't fit is replaced with '@' lines.
"  uhex      Show unprintable characters hexadecimal as <xx>
"            instead of using ^C and ~C.
set display+=lastline
" set display+=uhex

" Buffer switching behaviors
" useopen   If included, jump to the first open window that
"           contains the specified buffer (if there is one).
" split     If included, split the current window before loading a buffer
set switchbuf+=useopen
" set switchbuf+=split

" Longer commandline history
if has('cmdline_hist')
  set history=500
endif

" Viminfo file behavior
if has('viminfo')
  if ! exists('$VIMINFO')
    if has("win32")
      let $VIMINFO = $HOME . '/_viminfo'
    else
      let $VIMINFO = $HOME . '/.viminfo'
    endif
  endif
  " f1  store file marks
  " '   # of previously edited files to remember marks for
  " :   # of lines of command history
  " /   # of lines of search pattern history
  " <   max # of lines for each register to be saved
  " s   max # of Kb for each register to be saved
  " h   don't restore hlsearch behavior
  set viminfo=f1,'1000,:1000,/1000,<1000,s100,h,n$VIMINFO
endif

set backspace=indent,eol,start
set noshowmatch
set formatoptions=crqn

" Case insensitivity
set ignorecase
set infercase

" No incremental searches or search highlighting
set noincsearch
set nohlsearch

" Syntax for printing
set popt+=syntax:y
set popt+=number:y
set popt+=paper:letter
set popt+=left:5pc

" Don't automatically write buffers on switch
set noautowrite

" Allow editing of all types of files
if has('unix')
  set fileformats=unix,dos,mac
elseif has('mac')
  set fileformats=mac,unix,dos
else
  set fileformats=dos,unix,mac
endif

" Allow spaces in filenames
set isfname+=32

if has('gui_running')
  set lines=50
  set columns=112

  " Hide the mouse cursor while typing
  set mh

  " Automatically activate the window the mouse pointer is on
  set mousef

  " set go=Acgtm
  set go=Acga

  set columns=112
  set lines=50
endif

" Make operations like yank, which normally use the unnamed register, use the
" * register instead (yanks go to the system clipboard).
set clipboard=autoselect,unnamed
if has('gui_running') && has('unix')
  set clipboard+=exclude:cons\|linux
end

" Wrap at column 78
set tw=78

" Keep cursor in the same column if possible (see help).
set nostartofline

" Filter expected errors from make
" if has('eval') && v:version >= 700
"    let &makeprg = 'nice make $* 2>&1 \| sed -u -n '
"    let &makeprg.= '-e '/should fail/s/:\([0-9]\)/???\1/g' '
"    let &makeprg.= '-e 's/\([0-9]\{2\}\):\([0-9]\{2\}\):\([0-9]\{2\}\)/\1???\2???\3/g' '
"    let &makeprg.= '-e '/^/p' '
" endif

" Ignore binary files matched with grep by default
set grepformat=%f:%l:%m,%f:%l%m,%f\ \ %l%m,%-OBinary\ file%.%#

" Show the Vim7 tab line only when there is more than one tab page.
" See :he tab-pages for details.
try
  set showtabline = 1
catch
endtry

" Status Line {{{
set laststatus=2
if has('statusline')
  set statusline=
  set statusline+=%-3.3n\                      " buffer number
  set statusline+=%(%{StatusLine_FileName()}\ %) " filename
  set statusline+=%h%m%r%w                     " status flags

  " let Tlist_Process_File_Always = 1
  set statusline+=%((%{StatusLine_Tlist_Info()})\ %) " tag name

  " set statusline+=\[%{strlen(&ft)?&ft:'none'}] " file type
  set statusline+=%(\[%{&ft}]%)               " file type
  set statusline+=%=                          " right align remainder
  " set statusline+=0x%-8B                    " character value
  set statusline+=%-14(%l,%c%V%)              " line, character
  set statusline+=%<%P                        " file position
endif

if has('autocmd') && v:version >= 700
  " Special statusbar for special windows
  " NOTE: only Vim7+ supports a statusline local to a window
  augroup KergothStatusLines
    au!
    au FileType qf
          \ setlocal statusline=%2*%-3.3n%0* |
          \ setlocal statusline+=\ \[Compiler\ Messages\] |
          \ setlocal statusline+=%=%2*\ %<%P |
          \ let w:numberoverride = 1 |
          \ setlocal nonumber

    au VimEnter,BufWinEnter __Tag_List__
          \ setlocal statusline=\[Tags\] |
          \ setlocal statusline+=%= |
          \ setlocal statusline+=%l

    au VimEnter,BufWinEnter TreeExplorer let w:numberoverride = 1 | setlocal nonumber
  augroup END

  augroup KergothSpell
    au!
    " Don't enable spellchecking in unmodifiable buffers
    " NOTE: we hook these particular events because that's how
    " minibufexpl sets up its autoupdate.
    au BufEnter,BufWinEnter,BufLeave * if &ma == 0 | setlocal nospell | endif
    au BufEnter,BufWinEnter,BufLeave * if &fenc != '' && &fenc != &encoding | setlocal nospell | endif

    " Disable spell checking in all filetypes but text by default
    au FileType * setlocal nospell
  augroup END
endif
" }}}

" Encoding {{{
" Termencoding will reflect the current system locale, but internally,
" we use utf-8, and for files, we use whichever encoding from
" &fileencodings was detected for the file in question.
let &termencoding = &encoding
if has('multi_byte')
  set encoding=utf-8
  " fileencoding value is used for new files
  let &fileencoding = &encoding
  set fileencodings=ucs-bom,utf-8,default,latin1
  " set bomb
endif

" Most printers are Latin1, inform Vim so it can convert.
set printencoding=latin1
" }}}

if v:version >= 700
  " Default to omni completion using the syntax highlighting files
  set ofu=syntaxcomplete#Complete

  " Disable spell checking when in console, and enable it when in gui
  if has('gui_running')
    set spell spelllang=en_us
  else
    set nospell
  endif
endif

" Show nonprintable characters like hard tabs
"   NOTE: No longer showing trailing spaces this way, as those
"   are being highlighted in red, along with spaces before tabs.
set list

if (&termencoding == 'utf-8') || has('gui_running')
  set listchars=tab:»·,extends:…,precedes:…

  if v:version >= 700
    set listchars+=nbsp:‗
  endif

  if (! has('gui_running')) && (&t_Co < 3)
    set listchars+=trail:·
  endif
else
  set listchars=tab:>-,extends:>

  if v:version >= 700
    set listchars+=nbsp:_
  endif

  if (! has('gui_running')) && (&t_Co < 3)
    set listchars+=trail:.
  endif
endif
" }}}

" Colors {{{
" Make sure the gui is initialized before setting up syntax and colors
if has('gui_running')
  gui
endif

if has('syntax')
  syntax enable
endif

" Inside of screen, we don't care about colorterm
if &term !~ '^screen'
  " Set colors to 16 for gnome-terminal and xfce4-terminal
  if ($COLORTERM == 'gnome-terminal') || ($COLORTERM == 'Terminal')
    set t_Co=16
  elseif ($COLORTERM == 'rxvt-xpm') && (&term == 'rxvt')
    " try to set colors correctly for mrxvt
    set t_Co=256
  elseif ($COLORTERM == 'putty')
    set t_Co=256
  endif
endif

if &t_Co > 2 || has('gui_running')
  if exists('g:colors_name')
      unlet g:colors_name
  endif
  set background=dark

  colo baycomb

  " Colors red both trailing whitespace:
  "  foo   
  "  bar	
  " And spaces before tabs:
  "  foo 	bar
  hi def link RedundantWhitespace Error
  match RedundantWhitespace /\s\+$\| \+\ze\t/

  " Highlighting of Vim modelines, and hiding of fold markers
  hi def link vimModeline Special
  hi def link foldMarker SpecialKey
  if has('autocmd')
    augroup KergothMatches
      au!
      au BufRead,BufNewFile * syn match foldMarker contains= contained /{{{[1-9]\?\|}}}[1-9]\?/
      au BufRead,BufNewFile * syn match vimModeline contains= contained /vim:\s*set[^:]\{-1,\}:/
    augroup END
  endif
endif
" }}}

" Autocommands {{{
if has('autocmd')
  augroup Kergoth
    au!

    " Smart cursor positioning for emails, courtesy tip#1240
    au BufReadPost mutt* :Fip

    " Reload file with the correct encoding if fenc was set in the modeline
    au BufReadPost * let b:reloadcheck = 1
    au BufWinEnter *
          \ if exists('b:reloadcheck') |
          \   if &mod != 0 && &fenc != '' |
          \     exe 'e! ++enc=' . &fenc |
          \   endif |
          \   unlet b:reloadcheck |
          \ endif

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on GVim).
    au BufReadPost *
          \ if line("'\"") > 0 && line ("'\"") <= line('$') |
          \   exe "normal g'\"" |
          \ endif

    " Set the compiler to the filetype by default
    au FileType * try | exe 'compiler ' . &filetype | catch | endtry

    try
      " if we have a Vim which supports QuickFixCmdPost (Vim7),
      " give us an error window after running make, grep etc, but
      " only if results are available.
      au QuickFixCmdPost * botright cwindow 5
    catch
    endtry

    " Close out the quickfix window if it's the only open window
    fun! <SID>QuickFixClose()
      if &buftype == 'quickfix'
        " if this window is last on screen quit without warning
        if winbufnr(2) == -1
          quit!
        endif
      endif
    endfun
    au BufEnter * call <SID>QuickFixClose()

    " Change the current directory to the location of the
    " file being edited.
    com! -nargs=0 -complete=command Bcd lcd %:p:h

    " Special less.sh and man modes {{{
    fun! <SID>check_pager_mode()
      if exists('g:loaded_less') && g:loaded_less
        " we're in vimpager / less.sh / man mode
        set laststatus=0
        set ruler
        set foldmethod=manual
        set foldlevel=99
        set nolist
        " Make <space> in normal mode go down a page rather than left a
        " character
        noremap <space> <C-f>
      endif
    endfun
    au VimEnter * :call <SID>check_pager_mode()
    " }}}

    " Reload the vimrc when it changes
    autocmd BufWritePost $MYVIMRC nested source %
  augroup END " augroup Kergoth
endif " has('autocmd')
" }}}

" Syntax options {{{
let g:xml_syntax_folding = 1
let d_hl_operator_overload = 1
let g:doxygen_enhanced_color = 0
let g:html_use_css = 1
let g:use_xhtml = 1
let g:perl_extended_vars = 1
let g:sh_fold_enabled = 1
let g:c_gnu = 1
let g:c_posix = 1
let g:c_math = 1
let g:c_C99 = 1
let g:c_C94 = 1
let g:c_impl_defined = 1
" let g:perl_fold = 1
" let g:sh_minlines = 500
" }}}

" Plugin options {{{
let g:snips_author = 'Chris Larson <clarson@kergoth.com>'
let g:debianfullname = 'Chris Larson'
let g:debianemail = 'clarson@kergoth.com'
let g:yankring_history_dir = $MYVIMRUNTIME
let g:yankring_persist = 0
let g:GetLatestVimScripts_allowautoinstall = 0
let g:LustyExplorerSuppressRubyWarning = 1
let g:LargeFile = 10
let g:git_diff_spawn_mode = 1
let g:secure_modelines_verbose = 1
let g:secure_modelines_allowed_items = [
            \ "textwidth",    "tw",
            \ "softtabstop",  "sts",
            \ "tabstop",      "ts",
            \ "shiftwidth",   "sw",
            \ "expandtab",    "et",   "noexpandtab", "noet",
            \ "filetype",     "ft",
            \ "fileencoding", "fenc",
            \ "foldmethod",   "fdm",
            \ "foldlevel",    "fdl",
            \ "readonly",     "ro",   "noreadonly", "noro",
            \ "rightleft",    "rl",   "norightleft", "norl",
            \ "wrap", "nowrap",
            \ ]
let g:SuperTabDefaultCompletionType = "<C-X><C-O>"
let g:Tb_MinSize = 1
let g:Tb_MaxSize = 1
let g:Tb_SplitBelow = 0
let g:Tb_VSplit = 0
let g:Tb_cTabSwitchBufs = 0
let g:Tb_cTabSwitchWindows = 0
let loaded_bettermodified = 1
let g:NERD_shut_up = 1
let g:NERD_comment_whole_lines_in_v_mode = 1
let g:NERD_left_align_regexp = '.*'
let g:NERD_right_align_regexp = '.*'
let g:NERD_space_delim_filetype_regexp = '.*'
let g:HL_HiCurLine = 'StatusLine'
let g:Modeliner_format = 'fenc= sts= sw= ts= et'
let b:super_sh_indent_echo = 0
" rcsvers.vim {{{
let g:rvTempDir = '/tmp'
" Shared rcs save directory
" let g:rvSaveDirectoryType = 1
let g:rvSaveDirectoryName = '.rcs/'
" let g:rvSaveIfPreviousRCSFileExists = 0
" let g:rvSaveIfRCSExists = 0
let g:rvDescMsgPrompt = 0
" let g:rvExcludeExpression = '\c\.usr\|\c\.tmp|\c.swp'
let g:rvIncludeExpression = ''
if has('win32') && ! has('gui_win32')
  let g:rvUseCygPathFiltering = 1
endif
" }}}

" Explorer/Tags/Windows options {{{
let g:Tlist_Exit_OnlyWindow = 1
let g:Tlist_Show_Menu = 0
let g:Tlist_Enable_Fold_Column = 0
let g:Tlist_WinWidth = 28
let g:Tlist_Compact_Format = 1
let g:Tlist_File_Fold_Auto_Close = 1
let g:Tlist_Use_Right_Window = 1
let g:Tlist_Sort_Type = 'order'
let g:Tlist_Close_On_Select = 0
if has('gui_running')
  let g:Tlist_Inc_Winwidth = 1
else
  let g:Tlist_Inc_Winwidth = 0
endif

let g:miniBufExplModSelTarget = 1
let g:miniBufExplMinSize = 1
let g:miniBufExplMaxSize = 1

let g:treeExplVertical = 1
let g:treeExplDirSort = 1
let g:treeExplindent = 3
let g:treeExplWinSize = 28
let g:treeExplMinSize = 30

let g:bufExlporerDefaultHelp = 0
let g:bufExplorerSortBy = 'mru'
let g:bufExplorerSplitType = 'v'
let g:bufExplorerOpenMode = 1
" }}}
" }}}
