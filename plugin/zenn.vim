vim9script

if exists('g:loaded_ctrlp_zenn') || !exists('g:loaded_ctrlp')
  finish
endif
g:loaded_ctrlp_zenn = true

scriptencoding utf-8

# 設定変数: Zennの記事や本を格納している親ディレクトリのルート（デフォルト: カレントディレクトリ '.'）
g:ctrlp_zenn_root = get(g:, 'ctrlp_zenn_root', '.')

command! CtrlPZenn call ctrlp#init(ctrlp#zenn#Id())