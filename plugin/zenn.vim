vim9script

if exists('g:loaded_ctrlp_zenn')
  finish
endif
g:loaded_ctrlp_zenn = true

g:ctrlp_zenn_root = get(g:, 'ctrlp_zenn_root', '.')

command! CtrlPZenn call ctrlp#init(ctrlp#zenn#Id())