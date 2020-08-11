if exists('g:fern_renderer_devicons_loaded')
  finish
endif
let g:fern_renderer_devicons_loaded = 1

call extend(g:fern#renderers, {
      \ 'devicons': function('fern#renderer#devicons#new'),
      \})

if !exists('g:fern_renderer_devicons_disable_warning')
  call fern#logger#warn('fern-renderer-devicons.vim has deprecated. Use fern-renderer-nerdfont.vim instead.')
  call fern#logger#warn('To disable this warning, add "let g:fern_renderer_devicons_disable_warning = 1" on .vimrc')
endif
