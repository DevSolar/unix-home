compiler msbuild

function! s:GetMakePrg()
    let l:cur_dir = expand('%:p:h')

    " Makefile is preferred
    if executable('make') && !empty(findfile('Makefile', l:cur_dir . ';'))
        return 'make'
    endif

    " MSVC is the fallback
    let l:parent = l:cur_dir

    while l:parent != fnamemodify(l:parent, ':h')
        " Look for .sln
        let l:found = globpath(l:parent, '*.sln', 0, 1)

        if ! empty(l:found)
            return 'msbuild ' . fnameescape(l:found[0])
        endif

        " Look for .vcxproj
        let l:found = globpath(l:parent, '*.vcxproj', 0, 1)

        if ! empty(l:found)
            return 'msbuild ' . fnameescape(l:found[0])
        endif

        " Up one level
        let l:parent = fnamemodify(l:parent, ':h')
    endwhile

    " If all this fails, we'll fail on the default
    return 'make'
endfunction

let &l:makeprg = s:GetMakePrg()

" MSVC Format
let s:msvc_efm = '%f(%l):%multiline,%f(%l\\,%c):%multiline'
" GCC/Clang Format
let s:gnu_efm  = '%f:%l:%c:\ %t%*[^:]:\ %m,%f:%l:\ %t%*[^:]:\ %m'

let &l:errorformat = s:msvc_efm . ',' . s:gnu_efm
