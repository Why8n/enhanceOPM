" enhancement of vim's build-in operator-pending mappings
" Maintainer: Why8n
" License: MIT license


" a hook to disable plugin
if exists("g:loaded_enhanceOPM")
    finish
endif
let g:loaded_enhanceOPM = 1

let s:save_cpoptions = &cpoptions
set cpo&vim

" fun! s:backupVisualSelectionArea()
"     return [getpos("'<"), getpos("'>")]
" endf
"
" fun! s:restoreVisualSelectionArea(start, end)
"     call setpos("'<", a:start)
"     call setpos("'>", a:end)
" endf


for tob in ['()', '[]', '{}', '<>', '*', ',']
    call enhanceOPM#EOPM(tob)
endfor

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions


