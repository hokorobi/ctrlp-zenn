vim9script

if exists('g:loaded_ctrlp_zenn_autoload')
  finish
endif
g:loaded_ctrlp_zenn_autoload = 1

g:ctrlp_ext_vars = get(g:, 'ctrlp_ext_vars', []) -> add({
  init: 'ctrlp#zenn#Init()',
  accept: 'ctrlp#zenn#Accept',
  lname: 'Zenn Contents',
  sname: 'zenn',
  type: 'path',
  sort: 0,
})

var root_dir = get(g:, 'ctrlp_zenn_root', '.')
var zenn_title_map: dict<string> = {}

var IndexId = ctrlp#getvar('g:ctrlp_builtins') + len(g:ctrlp_ext_vars)
export def Id(): number
  return IndexId
enddef

# Definition of item structure for the candidate list
type Item = dict<any>

export def Init(): list<string>
  zenn_title_map = {}
  var items: list<Item> = []

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

      # Add item including modification time (getftime)
      items->add({
        label: label,
        mtime: getftime(file),
      })
    endfor
  endfor

  # Sort by modification time in descending order (newest file first)
  items->sort((a, b) => b.mtime - a.mtime)

  # Build and return a strictly typed list<string>
  var display_lines: list<string> = []
  for item in items
    display_lines->add(item.label)
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