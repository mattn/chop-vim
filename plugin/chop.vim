function! s:chop()
  let res = webapi#http#post('http://chopapp.com/code_snips', {
  \  'code': getline(1, '$'),
  \  'language': &ft,
  \})
  if res.status !~ '^2'
    echohl ErrorMsg | echomsg res.message | echohl None
    return
  endif
  echomsg printf('http://chopapp.com/#%s', webapi#json#decode(res.content)['token'])
endfunction

command! Chop call s:chop()