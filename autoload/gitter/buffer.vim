let s:name = 'gitter'

function! gitter#buffer#open(uri) abort
  let uri = substitute(a:uri, '^gitter://', '', '')
  if uri == 'rooms'
    " TODO: implement this
    call denops#notify(s:name, 'selectRooms', [])
  elseif uri =~ '^input/[A-Za-z0-9]\+$'
    setlocal bufhidden=wipe buftype=acwrite noswapfile filetype=markdown
    autocmd gitter_internal BufWriteCmd <buffer> setlocal nomodified
    nnoremap <buffer> q <Cmd>call <SID>close_input()<CR>
  elseif uri =~ '\v^room/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/?$'
    setlocal filetype=gitter
    call denops#notify(s:name, 'loadRoom', [substitute(uri, '\v^room/|/?$', '', 'g')])
  else
    call setline(1, 'You accessed wrong named buffer')
  endif
endfunction

" @param bufnr number
" @param entry { name: string, text: string, sent: string }
function! gitter#buffer#update(bufnr, entries) abort
  call setbufvar(a:bufnr, '&modifiable', v:true)
  for entry in a:entries
    call appendbufline(a:bufnr, '$', [
          \ repeat('-', 80), printf('@%-55s%s', entry.name, entry.sent),
          \ ] + split(entry.text, "\n"))
  endfor
  call setbufvar(a:bufnr, '&modifiable', v:false)
endfunction

function! s:close_input() abort
  if &l:modified
    call gitter#util#warn('Your changes are not saved')
  else
    call denops#notify(s:name, 'sendMessage', [
          \ matchstr(bufname(), '^gitter://input/\zs[A-Za-z0-9]\+$'),
          \ join(getline(1, '$'), "\n")
          \ ])
    close
    if exists('g:gitter#_parent_winid')
      call win_gotoid(g:gitter#_parent_winid)
    endif
  endif
endfunction
