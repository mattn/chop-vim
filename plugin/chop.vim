function! s:comment(line1, line2)
  if !exists('b:chop_id')
    echohl ErrorMsg | echomsg "This buffer's not chopped" | echohl None
    return
  endif
  let text = input('Comment: ')
  if len(text) == 0
    return
  endif
  let res = webapi#http#post('http://chopapp.com/notes', {
  \  'code_snip_id': b:chop_id,
  \  'isNew': 1,
  \  'line_start': a:line1-1,
  \  'line_end': a:line2-1,
  \  'text': text,
  \})
  if res.status !~ '^2'
    echohl ErrorMsg | echomsg res.message | echohl None
    return
  endif
  echomsg 'Commented!'
endfunction

function! s:chop(id)
  if len(a:id) == 0
    let res = webapi#http#post('http://chopapp.com/code_snips', {
    \  'code': join(getline(1, '$'), "\n"),
    \  'language': &ft,
    \})
    if res.status !~ '^2'
      echohl ErrorMsg | echomsg res.message | echohl None
      return
    endif
    let b:chop_id = webapi#json#decode(res.content)['token']
    echomsg printf('http://chopapp.com/#%s', b:chop_id)
  else
    let res = webapi#http#get(printf('http://chopapp.com/code_snips/%s', a:id))
    if res.status !~ '^2'
      echohl ErrorMsg | echomsg res.message | echohl None
      return
    endif
    silent noautocmd new
    setlocal noswapfile
    let old_undolevels = &undolevels
    set undolevels=-1
    silent %d _
    let lines = webapi#json#decode(res.content)['lines']
    for line in range(len(lines))
      let html = '<div>' . lines[line] . '</div>'
      let v = webapi#html#decodeEntityReference(webapi#html#parse(html).value())
      call setline(line, v)
    endfor
    let &undolevels = old_undolevels
    let b:chop_id = a:id
  endif
endfunction

command! -nargs=? Chop call s:chop(<q-args>)
command! -range ChopComment call s:comment(<line1>, <line2>)
