autocmd BufNewFile,BufRead *.cmd call s:DetectPowerShell()

" A useful little hack to make PowerShell scripts runnable by double
" clicking on them is making them a .cmd/.ps1 'chimera': Start as a
" .cmd, execute as a PowerShell. Add this to the beginning of the file:
"
" <# : batch prelude (https://stackoverflow.com/a/33065387/60281)
" @echo off
" PowerShell -ExecutionPolicy Bypass -NoProfile -NoLogo "iex (${%~f0} | out-string)"
" Exit /b %errorlevel%
" : end batch prelude #>
"
" Save the file with the .cmd extension.
"
" The function below detects files beginning like that, and corrects
" the filetype so you get proper PS1 syntax highlighting.

function! s:DetectPowerShell()
    let l:first_line = getline(1)
    let l:third_line = getline(3)
    if l:first_line =~ '^<#' && l:third_line =~ 'PowerShell'
        set filetype=ps1
    endif
endfunction
