fun! utils#getChar(lineStr, colPos)
    " let pos = strchars(a:lineStr) - 1
    " if a:colPos <? pos
    "     let pos = a:colPos
    " endif
    " return strcharpart(a:lineStr, pos, 1)
    return a:lineStr[a:colPos]
endf

fun! utils#insertStr(str)
    let tmp = @a
    let @a = a:str
    execute 'normal! "ap'
    let @a = tmp
endf
