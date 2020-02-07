scriptencoding utf-8

let s:PATTERN = '^$~.*[]\'
let s:Config = vital#fern#import('Config')
let s:AsyncLambda = vital#fern#import('Async.Lambda')

let s:STATUS_NONE = g:fern#STATUS_NONE
let s:STATUS_COLLAPSED = g:fern#STATUS_COLLAPSED

function! fern#renderer#devicons#new() abort
  let default = fern#renderer#default#new()
  if !exists('*WebDevIconsGetFileTypeSymbol')
    call fern#logger#error("WebDevIconsGetFileTypeSymbol is not found. 'devicons' renderer requires 'ryanoasis/vim-devicons'.")
    return default
  endif
  return extend(copy(default), {
        \ 'render': funcref('s:render'),
        \ 'syntax': funcref('s:syntax'),
        \})
endfunction

function! s:render(nodes, marks) abort
  let options = {
        \ 'leading': g:fern#renderer#devicons#leading,
        \ 'marked_symbol': g:fern#renderer#devicons#marked_symbol,
        \ 'unmarked_symbol': g:fern#renderer#devicons#unmarked_symbol,
        \}
  let base = len(a:nodes[0].__key)
  let Profile = fern#profile#start("fern#renderer#devicons#s:render")
  return s:AsyncLambda.map(copy(a:nodes), { v, -> s:render_node(v, a:marks, base, options) })
        \.finally({ -> Profile() })
endfunction

function! s:syntax() abort
  syntax clear
  syntax match FernLeaf   /^\s*[^ ]\+/
  syntax match FernBranch /^\s*.*\/$/
  syntax match FernRoot   /\%1l.*/
  execute printf(
        \ 'syntax match FernMarked /^%s.*/',
        \ escape(g:fern#renderer#devicons#marked_symbol, s:PATTERN),
        \)
endfunction

function! s:render_node(node, marks, base, options) abort
  let prefix = index(a:marks, a:node.__key) is# -1
        \ ? a:options.unmarked_symbol
        \ : a:options.marked_symbol
  let level = len(a:node.__key) - a:base
  if level is# 0
    return prefix . a:node.label . '/'
  endif
  let leading = repeat(a:options.leading, level - 1)
  let symbol = s:get_node_symbol(a:node)
  let suffix = a:node.status ? '/' : ''
  return prefix . leading . symbol . a:node.label . suffix
endfunction

function! s:get_node_symbol(node) abort
  if a:node.status is# s:STATUS_NONE
    let symbol = WebDevIconsGetFileTypeSymbol(a:node.bufname, 0)
  elseif a:node.status is# s:STATUS_COLLAPSED
    let symbol = WebDevIconsGetFileTypeSymbol(a:node.bufname, 1)
  else
    let symbol = g:DevIconsDefaultFolderOpenSymbol
  endif
  return symbol . '  '
endfunction

call s:Config.config(expand('<sfile>:p'), {
      \ 'leading': ' ',
      \ 'marked_symbol': '✓  ',
      \ 'unmarked_symbol': '   ',
      \})
