vim9script

var ctrlp_builtins = ctrlp#getvar('g:ctrlp_builtins')
var ZennExtVar = {
  lname: 'Zenn Contents',
  sname: 'zenn',
  type: 'path',
  sort: 0,
}
ZennExtVar.init = 'ctrlp#zenn#Init()'
ZennExtVar.accept = 'ctrlp#zenn#Accept'
g:ctrlp_ext_vars = get(g:, 'ctrlp_ext_vars', []) -> add(ZennExtVar)

var IndexId = ctrlp_builtins + len(g:ctrlp_ext_vars)
var root_dir = get(g:, 'ctrlp_zenn_root', '.')
var zenn_title_map: dict<string> = {}

export def Id(): number
  return IndexId
enddef

export def Init(): list<string>
  zenn_title_map = {}
  var display_lines: list<string> = []

  var target_dirs = ['articles', 'books']

  for target in target_dirs
    var base_dir = printf('%s/%s', root_dir, target)->fnamemodify(':p')
    if !isdirectory(base_dir)
      continue
    endif

    var files = globpath(base_dir, '**/*.md', 0, 1)

    for file in files
      if !filereadable(file)
        continue
      endif

      var title = ''
      for line in readfile(file, '', 30)
        if line =~# '^title:\s*'
          title = substitute(line, '^title:\s*["'']\?\(.\{-}\)["'']\?\s*$', '\1', '')
          break
        endif
      endfor
      if empty(title)
        continue
      endif

      var label = title

      # Appended identifiers to all items except articles.
      if target !=# 'articles'
        label ..= ' (' .. target .. ')'
      endif

      zenn_title_map[label] = file
      add(display_lines, label)
    endfor
  endfor

  return display_lines
enddef

export def Accept(action: string, str: string)
  ctrlp#exit()
  if has_key(zenn_title_map, str)
    var filepath = zenn_title_map[str]
    execute 'edit' fnameescape(filepath)
  endif
enddef