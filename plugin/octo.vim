if exists('g:loaded_octo')
  finish
endif

command! NewComment :lua require('octo').new_comment()
command! CloseIssue :lua require('octo').change_issue_state('closed')
command! ReopenIssue :lua require('octo').change_issue_state('open')
command! SaveIssue  :lua require('octo').save_issue()
command! -nargs=? NewIssue   :lua require('octo').new_issue(<f-args>)
command! -nargs=+ Issue :lua require('octo').get_issue(<f-args>)
"command! -nargs=? ListIssues :lua require('octo').list_issues(<f-args>)

function! octo#fzf_menu(candidates, callback) abort
    call fzf#run(fzf#wrap({
        \ 'source': a:candidates,
        \ 'sink': function('octo#result_dispatcher', [a:callback]),
        \ 'options': '+m --with-nth 2.. -d "::"',
        \ }))
endfunction

function! octo#result_dispatcher(callback, result) abort
    let iid = split(a:result, '::')[0]
    call luaeval('require("octo")[_A[1]](_A[2])', [a:callback, iid])
endfunction

function! octo#clear_history() abort
  let old_undolevels = &undolevels
  set undolevels=-1
  exe "normal a \<BS>\<Esc>"
  let &undolevels = old_undolevels
  unlet old_undolevels
endfunction

let s:no = nvim_win_get_option(0,'number')
let s:clo = nvim_win_get_option(0,'cursorline')
let s:sco = nvim_win_get_option(0,'signcolumn')
let s:wo = nvim_win_get_option(0,'wrap')

function! octo#configure_win() abort
  let s:no = nvim_win_get_option(0,'number')
  let s:clo = nvim_win_get_option(0,'cursorline')
  let s:sco = nvim_win_get_option(0,'signcolumn')
  let s:wo = nvim_win_get_option(0,'wrap')

  call nvim_win_set_option(0,'number', v:false)
  call nvim_win_set_option(0,'cursorline', v:false)
  call nvim_win_set_option(0,'signcolumn', 'yes')
  call nvim_win_set_option(0,'wrap', v:true)

endfunction

function! octo#restore_win() abort
  call nvim_win_set_option(0,'number', s:no)
  call nvim_win_set_option(0,'cursorline', s:clo)
  call nvim_win_set_option(0,'signcolumn', s:sco)
  call nvim_win_set_option(0,'wrap', s:wo)
endfunction

autocmd BufNew,BufEnter * if &ft == 'octo_issue' | call octo#configure_win() | endif 
autocmd BufLeave * if &ft == 'octo_issue' | call octo#restore_win() | endif 

let g:loaded_octo = 1
