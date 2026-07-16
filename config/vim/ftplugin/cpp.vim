compiler msbuild

function! s:GetMakePrg()
    let l:cur_dir = expand('%:p:h')

    " Makefile is preferred
    if executable('make') && !empty(findfile('Makefile', l:cur_dir . ';'))
        return 'make'
    endif

    " MSVC is the fallback
    " Two passes: prefer .sln (full upward traversal) over .vcxproj,
    " so a .vcxproj in a subdirectory doesn't shadow the root .sln.
    for l:pattern in ['*.sln', '*.vcxproj']
        let l:parent = l:cur_dir
        while l:parent != fnamemodify(l:parent, ':h')
            let l:found = globpath(l:parent, l:pattern, 0, 1)
            if !empty(l:found)
                return 'msbuild ' . fnameescape(l:found[0])
            endif
            let l:parent = fnamemodify(l:parent, ':h')
        endwhile
    endfor

    " If all this fails, we'll fail on the default
    return 'make'
endfunction

let &l:makeprg = s:GetMakePrg()

" MSVC Format: file(line,col): error/warning CXXXX: message [project]
let s:msvc_efm = '%f(%l\,%c):\ %t%*[^\ ]\ %m,%f(%l):\ %t%*[^\ ]\ %m'
" GCC/Clang Format
let s:gnu_efm  = '%f:%l:%c:\ %t%*[^:]:\ %m,%f:%l:\ %t%*[^:]:\ %m'

let &l:errorformat = s:msvc_efm . ',' . s:gnu_efm
