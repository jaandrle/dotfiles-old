" Fold expressions {{{1
function! StackedMarkdownFolds()
  let line = getline(v:lnum)
  let prevline = getline(v:lnum - 1)
  let nextline = getline(v:lnum + 1)
  " fenced block
  if line =~ '^```.*$' && prevline =~ '^\s*$'  " start of a fenced block
    return ">2"
  elseif line =~ '^```$' && nextline =~ '^\s*$'  " end of a fenced block
    return "<2"
  endif
  " headers
  if s:HeadingDepth(v:lnum)
    return ">1"
  endif
  " frontmatter
  if line =~ '^----*$'
    return v:lnum == 1 ? ">1" : '<1'
  endif
  return '='
endfunction

" Helpers {{{1
function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

function! s:HeadingDepth(lnum)
  if s:LineIsFenced(a:lnum) | return 0 | endif

  let thisline = getline(a:lnum)
  if thisline =~ '^#\+\s\+'
    return len(matchstr(thisline, '^#\{1,6}'))
  else
  if thisline != ''
    let prevline = getline(a:lnum - 1)
    let nextline = getline(a:lnum + 1)
    if (nextline =~ '^=\+$') && (prevline =~ '^\s*$')
      return 1
    elseif (nextline =~ '^-\+$') && (prevline =~ '^\s*$')
      return 2
    endif
  endif
  return 0
endfunction

function! s:LineIsFenced(lnum)
  if exists("b:current_syntax") && b:current_syntax ==# 'markdown' || &filetype ==# 'markdown'
    " It's cheap to check if the current line has 'markdownCode' syntax group
    return s:HasSyntaxGroup(a:lnum, '\vmarkdown(Code|Highlight)')
  else
    " Using searchpairpos() is expensive, so only do it if syntax highlighting
    " is not enabled
    return s:HasSurroundingFencemarks(a:lnum)
  endif
endfunction

function! s:HasSyntaxGroup(lnum, targetGroup)
  let syntaxGroup = map(synstack(a:lnum, 1), 'synIDattr(v:val, "name")')
  for value in syntaxGroup
    if value =~ a:targetGroup
        return 1
    endif
  endfor
endfunction

function! s:HasSurroundingFencemarks(lnum)
  let cursorPosition = [line("."), col(".")]
  call cursor(a:lnum, 1)
  let startFence = '\%^```\|^\n\zs```'
  let endFence = '```\n^$'
  let fenceEndPosition = searchpairpos(startFence,'',endFence,'W')
  call cursor(cursorPosition)
  return fenceEndPosition != [0,0]
endfunction

function! s:FoldText()
  if getline(v:foldstart) =~ '^----*$'
      let title= ''
      let i= v:foldstart+1
      let I= v:foldend
      while i<I && title !~ '^title'
          let title= getline(i)
          let i+= 1
      endwhile
      if title !~ '^title'
        let title= 'Front Matter'
      endif
      return title
  endif
  let indent = repeat('#', s:HeadingDepth(v:foldstart))
  let title = substitute(getline(v:foldstart), '^#\+\s\+', '', '')
  let foldsize = (v:foldend - v:foldstart)
  let linecount = '['.foldsize.' line'.(foldsize>1?'s':'').']'
  return indent.' '.title.' '.linecount.' '
endfunction

function! FoldMarkdownToggle()
  if &l:foldexpr ==# 'StackedMarkdownFolds()'
    setlocal foldmethod< foldtext< foldexpr<
  else
    setlocal foldmethod=expr
    let &l:foldtext = s:SID().'FoldText()'
    let &l:foldexpr = 'StackedMarkdownFolds()'
  endif
endfunction

" Teardown {{{1
if !exists("b:undo_ftplugin") | let b:undo_ftplugin = '' | endif
let b:undo_ftplugin .= '
  \ | setlocal foldmethod< foldtext< foldexpr<
  \ '
" vim:set fdm=marker:
