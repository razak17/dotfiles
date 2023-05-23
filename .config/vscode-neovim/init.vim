" Ref: https://github.com/Bekaboo/nvim/blob/master/plugin/vscode-neovim.vim
if !exists('g:vscode')
  finish
endif

" WhichKey
function! s:openWhichKeyInVisualMode()
    normal! gv
    let visualmode = visualmode()
    if visualmode == "V"
        let startLine = line("v")
        let endLine = line(".")
        call VSCodeNotifyRange("whichkey.show", startLine, endLine, 1)
    else
        let startPos = getpos("v")
        let endPos = getpos(".")
        call VSCodeNotifyRangePos("whichkey.show", startPos[1], endPos[1], startPos[2], endPos[2], 1)
    endif
endfunction

nnoremap <silent> <Space> :call VSCodeNotify('whichkey.show')<CR>
xnoremap <silent> <Space> :<C-u>call <SID>openWhichKeyInVisualMode()<CR>

" Comment
function! s:vscodeCommentary(...) abort
    if !a:0
        let &operatorfunc = matchstr(expand('<sfile>'), '[^. ]*$')
        return 'g@'
    elseif a:0 > 1
        let [line1, line2] = [a:1, a:2]
    else
        let [line1, line2] = [line("'["), line("']")]
    endif

    call VSCodeCallRange("editor.action.commentLine", line1, line2, 0)
endfunction

xmap gc  <Plug>VSCodeCommentary
nmap gc  <Plug>VSCodeCommentary
omap gc  <Plug>VSCodeCommentary
nmap gcc <Plug>VSCodeCommentaryLine

" LSP keymap settings
function! s:vscodeGoToDefinition(str)
    if exists('b:vscode_controlled') && b:vscode_controlled
        call VSCodeNotify('editor.action.' . a:str)
    else
        " Allow to function in help files
        exe "normal! \<C-]>"
    endif
endfunction

nnoremap K <Cmd>call VSCodeNotify('editor.action.showHover')<CR>
nnoremap gD <Cmd>call <SID>vscodeGoToDefinition('revealDeclaration')<CR>
nnoremap gd <Cmd>call <SID>vscodeGoToDefinition('revealDefinition')<CR>
nnoremap <C-]> <Cmd>call <SID>vscodeGoToDefinition('revealDefinition')<CR>
nnoremap gO <Cmd>call VSCodeNotify('workbench.action.gotoSymbol')<CR>
nnoremap <leader>K <Cmd>call VSCodeNotify('editor.action.peekDeclaration')<CR>
nnoremap <leader>k <Cmd>call VSCodeNotify('editor.action.peekDefinition')<CR>
nnoremap <leader>R <Cmd>call VSCodeNotify('editor.action.referenceSearch.trigger')<CR>
nnoremap gr <Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>

xnoremap K <Cmd>call VSCodeNotify('editor.action.showHover')<CR>
xnoremap gD <Cmd>call <SID>vscodeGoToDefinition('revealDeclaration')<CR>
xnoremap gd <Cmd>call <SID>vscodeGoToDefinition('revealDefinition')<CR>
xnoremap <C-]> <Cmd>call <SID>vscodeGoToDefinition('revealDefinition')<CR>
xnoremap gO <Cmd>call VSCodeNotify('workbench.action.gotoSymbol')<CR>
xnoremap <leader>k <Cmd>call VSCodeNotify('editor.action.peekDeclaration')<CR>
xnoremap <leader>K <Cmd>call VSCodeNotify('editor.action.peekDefinition')<CR>
xnoremap <leader>R <Cmd>call VSCodeNotify('editor.action.referenceSearch.trigger')<CR>

" Git keymap settings
nnoremap ]c <Cmd>call VSCodeNotify('workbench.action.editor.nextChange')<CR>
nnoremap [c <Cmd>call VSCodeNotify('workbench.action.editor.previousChange')<CR>

command! -complete=file -nargs=? Split call <SID>split('h', <q-args>)
command! -complete=file -nargs=? Vsplit call <SID>split('v', <q-args>)
command! -complete=file -nargs=? New call <SID>split('h', '__vscode_new__')
command! -complete=file -nargs=? Vnew call <SID>split('v', '__vscode_new__')
command! -bang Only if <q-bang> == '!' | call <SID>closeOtherEditors() | else | call VSCodeNotify('workbench.action.joinAllGroups') | endif

function! s:openVSCodeCommandsInVisualMode()
    normal! gv
    let visualmode = visualmode()
    if visualmode == "V"
        let startLine = line("v")
        let endLine = line(".")
        call VSCodeNotifyRange("workbench.action.showCommands", startLine, endLine, 1)
    else
        let startPos = getpos("v")
        let endPos = getpos(".")
        call VSCodeNotifyRangePos("workbench.action.showCommands", startPos[1], endPos[1], startPos[2], endPos[2], 1)
    endif
endfunction

xnoremap <silent> <C-P> :<C-u>call <SID>openVSCodeCommandsInVisualMode()<CR>

" Window and buffer keymap settings
function! s:split(...) abort
    let direction = a:1
    let file = exists('a:2') ? a:2 : ''
    call VSCodeCall(direction ==# 'h' ? 'workbench.action.splitEditorDown' : 'workbench.action.splitEditorRight')
    if !empty(file)
        call VSCodeExtensionNotify('open-file', expand(file), 'all')
    endif
endfunction

function! s:splitNew(...)
    let file = a:2
    call s:split(a:1, empty(file) ? '__vscode_new__' : file)
endfunction

function! s:closeOtherEditors()
    call VSCodeNotify('workbench.action.closeEditorsInOtherGroups')
    call VSCodeNotify('workbench.action.closeOtherEditors')
endfunction

function! s:manageEditorHeight(...)
    let count = a:1
    let to = a:2
    for i in range(1, count ? count : 1)
        call VSCodeNotify(to ==# 'increase' ? 'workbench.action.increaseViewHeight' : 'workbench.action.decreaseViewHeight')
    endfor
endfunction

function! s:manageEditorWidth(...)
    let count = a:1
    let to = a:2
    for i in range(1, count ? count : 1)
        call VSCodeNotify(to ==# 'increase' ? 'workbench.action.increaseViewWidth' : 'workbench.action.decreaseViewWidth')
    endfor
endfunction

" buffer management
nnoremap <C-w>n <Cmd>call <SID>splitNew('h', '__vscode_new__')<CR>
nnoremap <C-w>c <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>

xnoremap <C-w>n <Cmd>call <SID>splitNew('h', '__vscode_new__')<CR>
xnoremap <C-w>c <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>

" window/splits management
nnoremap <C-w>s <Cmd>call <SID>split('h')<CR>
nnoremap <C-w>v <Cmd>call <SID>split('v')<CR>
nnoremap <C-w>= <Cmd>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>
nnoremap <C-w>_ <Cmd>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>
nnoremap <C-w>+ <Cmd>call <SID>manageEditorHeight(v:count, 'increase')<CR>
nnoremap <C-w>- <Cmd>call <SID>manageEditorHeight(v:count, 'decrease')<CR>
nnoremap <C-w>> <Cmd>call <SID>manageEditorWidth(v:count, 'increase')<CR>
nnoremap <C-w>< <Cmd>call <SID>manageEditorWidth(v:count, 'decrease')<CR>
nnoremap <C-w>o <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>

xnoremap <C-w>s <Cmd>call <SID>split('h')<CR>
xnoremap <C-w>v <Cmd>call <SID>split('v')<CR>
xnoremap <C-w>= <Cmd>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>
xnoremap <C-w>_ <Cmd>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>
xnoremap <C-w>+ <Cmd>call <SID>manageEditorHeight(v:count, 'increase')<CR>
xnoremap <C-w>- <Cmd>call <SID>manageEditorHeight(v:count, 'decrease')<CR>
xnoremap <C-w>> <Cmd>call <SID>manageEditorWidth(v:count, 'increase')<CR>
xnoremap <C-w>< <Cmd>call <SID>manageEditorWidth(v:count, 'decrease')<CR>
xnoremap <C-w>o <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>

" window navigation
nnoremap <C-w>h <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
nnoremap <C-w>j <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
nnoremap <C-w>k <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
nnoremap <C-w>l <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>
nnoremap <C-w>H <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
nnoremap <C-w>J <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
nnoremap <C-w>K <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
nnoremap <C-w>L <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>
nnoremap <C-w>w <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
nnoremap <C-w>W <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>
nnoremap <C-w>p <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>

xnoremap <C-w>h <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
xnoremap <C-w>j <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
xnoremap <C-w>k <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
xnoremap <C-w>l <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>
xnoremap <C-w>H <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
xnoremap <C-w>J <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
xnoremap <C-w>K <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
xnoremap <C-w>L <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>
xnoremap <C-w>w <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
xnoremap <C-w>W <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>
xnoremap <C-w>p <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>

" Better Navigation
nnoremap <silent> <C-j> <Cmd>call VSCodeNotify('workbench.action.navigateDown')<CR>
xnoremap <silent> <C-j> <Cmd>call VSCodeNotify('workbench.action.navigateDown')<CR>
nnoremap <silent> <C-k> <Cmd>call VSCodeNotify('workbench.action.navigateUp')<CR>
xnoremap <silent> <C-k> <Cmd>call VSCodeNotify('workbench.action.navigateUp')<CR>
nnoremap <silent> <C-h> <Cmd>call VSCodeNotify('workbench.action.navigateLeft')<CR>
xnoremap <silent> <C-h> <Cmd>call VSCodeNotify('workbench.action.navigateLeft')<CR>
nnoremap <silent> <C-l> <Cmd>call VSCodeNotify('workbench.action.navigateRight')<CR>
xnoremap <silent> <C-l> <Cmd>call VSCodeNotify('workbench.action.navigateRight')<CR>

" Misc
nnoremap 0 ^
nnoremap $ g_
nnoremap Y y$
nmap <Tab> :Tabnext<CR>
nmap <S-Tab> :Tabprev<CR>
nmap L :Tabnext<CR>
nmap H :Tabprev<CR>
nnoremap <C-z> :undo<CR>
xnoremap K :m '<-2<CR>gv=gv
xnoremap J :m '>+1<CR>gv=gv
imap <expr> jk col('.') == 1 ? '<esc>' : '<esc>l'

" Paste in visual mode multiple times
xnoremap p pgvy

" search visual selection
vnoremap // y/<C-R>"<CR>

" Add Empty space above and below
nnoremap [<space> <cmd>put! =repeat(nr2char(10), v:count1)<cr>
nnoremap ]<space> <cmd>put =repeat(nr2char(10), v:count1)<cr>

" Better tabbing
vnoremap < <gv
vnoremap > >gv

" find visually selected text
vnoremap * y/<C-R>"<CR>

" make . work with visually selected lines
vnoremap . :norm.<CR>
