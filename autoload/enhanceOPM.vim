fun! s:searchPairChar(lhs,rhs)
    let curPos = getpos('.')

    let lineStr = getline(curPos[1])
    " total bytes (eg: abcd == 4)
    let endCol = col('$') - 1


    let pairLeftCount = 0
    let prePos = deepcopy(curPos)
    let postPos = deepcopy(curPos)
    let pos = curPos[2] - 1

    if utils#getChar(lineStr,curPos[2] - 1) ==? a:rhs
        let pos -= 1
    endif
    " found left
    while pos >=? 0
        let curChar = utils#getChar(lineStr, pos)
        if curChar ==? a:lhs
            let pairLeftCount += 1
            if pairLeftCount ==? 1
                let prePos[2] = pos + 1
                break
            endif
        elseif curChar ==? a:rhs
            let pairLeftCount -= 1
        endif
        let pos -= 1
    endwhile

    " left not found
    if pairLeftCount !=? 1
        let pairLeftCount = 0
    endif

    let pos = curPos[2] - 1
    if utils#getChar(lineStr, curPos[2] - 1) ==? a:lhs
        let pos += 1
    endif

    while pos <? endCol
        let curChar = utils#getChar(lineStr, pos)
        if curChar ==? a:lhs
            let pairLeftCount += 1
            if pairLeftCount ==? 1
                let prePos[2] = pos + 1
            endif
        elseif curChar ==? a:rhs
            let pairLeftCount -= 1
            if pairLeftCount ==? -1
                let pairLeftCount = 0
            elseif pairLeftCount ==? 0
                let postPos[2] = pos + 1
                break
            endif
        endif
        let pos += 1
    endwhile

    if !(pairLeftCount == 0 && prePos[2] < postPos[2])
        let prePos = curPos
        let postPos = curPos
    endif
    return [prePos, postPos]
endf

fun! s:searchSingleChar(char)
    let curPos = getpos('.')
    let prePos = deepcopy(curPos)
    let postPos = deepcopy(curPos)
    let lineStr = getline(curPos[1])
    let endCol = col('$') - 1
    let foundPost = 0

    let pos = curPos[2] - 1

    if utils#getChar(lineStr, pos) ==? a:char
        let pos -= 1
    endif

    while pos >=? 0
        if utils#getChar(lineStr, pos) ==? a:char
            let prePos[2] = pos + 1
            break
        endif
        let pos -= 1
    endwhile 

    let pos = curPos[2] - 1

    while pos <? endCol
        if utils#getChar(lineStr, pos) ==? a:char
            if prePos[2] ==? postPos[2]
                let prePos[2] = pos + 1
                " make a different position so we can justify
                let postPos[2] = pos
            else
                let postPos[2] = pos + 1
                let foundPost = 1
                break
            endif
        endif
        let pos += 1
    endwhile

    if !(foundPost && prePos[2] <? postPos[2])
        let prePos = curPos
        let postPos = curPos
    endif
    return [prePos, postPos]
endf

fun! s:traverse2Char(lhs, rhs) 
    let lineStr = getline('.')
    let endCol = col('$') - 1
    let curCol = col('.') - 1
    let pos = curCol
    " traverse left
    while pos >=? 0
        if utils#getChar(lineStr, pos) ==? a:rhs
            break
        endif
        if utils#getChar(lineStr, pos) ==? a:lhs
            let ret = pos + 1
            break
        endif
        let pos -= 1
    endwhile

    if !exists('l:ret')
        " traverse right
        let pos = curCol
        while pos <? endCol
            let curChar = utils#getChar(lineStr, pos)
            if curChar ==? a:lhs || curChar ==? a:rhs
                let ret = pos + 1
                break
            endif
            let pos += 1
        endwhile
    endif
    return exists('l:ret') ? ret : -1
endf

fun! enhanceOPM#AddTextObj(char, range) abort
    " let [vStart, vEnd] = s:backupVisualSelectionArea()

    if len(a:char) ==? 2
        let lhs = utils#getChar(a:char, 0)
        let rhs = utils#getChar(a:char, 1)
        let [prePos, postPos] = s:searchPairChar(lhs, rhs)
    elseif len(a:char) ==? 1
        let [prePos, postPos] = s:searchSingleChar(a:char)
    else
        echoerr a:char.' is not supported!'
        return
    endif

    if exists('l:prePos') && exists('l:postPos')
        if prePos[2] < postPos[2]
            " caculate characters length between lhs and rhs
            let offset = strchars(getline('.')[prePos[2]:postPos[2] - 2])
            " rhs - lhs
            let offset += 1
            call setpos('.', prePos)
            if a:range ==? 'i'
                if offset ==? 1
                    " todo::fix bugs for yi
                    call utils#insertStr(' ')
                    let offset += 1
                endif
                let offset -= 2
                let prePos[2] += 1
                call setpos('.', prePos)
            endif
            execute printf("normal! %s", offset == 0 ? 'v' : 'v'.offset.'l' )
        else
            " handle cross lines
            if len(a:char) ==? 2
                let pos = s:traverse2Char(lhs, rhs) 
                if pos != -1
                    let curPos = getpos('.')
                    let curPos[2] = pos
                    call setpos('.', curPos)
                    execute printf("normal! v%s%s", a:range, utils#getChar(a:char, 0))
                endif
            endif
        endif
    endif

    " call s:restoreVisualSelectionArea(vStart, vEnd)
endf

fun! enhanceOPM#EOPM(char)
    if len(a:char) ==? 2
        let lhs = a:char[0]
        let rhs = a:char[1]
        silent! execute printf("onoremap <silent> i%s :<c-u>call enhanceOPM#AddTextObj('%s', 'i')<CR>", lhs, a:char)
        silent! execute printf("onoremap <silent> a%s :<c-u>call enhanceOPM#AddTextObj('%s', 'a')<CR>", lhs, a:char)

        silent! execute printf("onoremap <silent> i%s :<c-u>call enhanceOPM#AddTextObj('%s', 'i')<CR>", rhs, a:char)
        silent! execute printf("onoremap <silent> a%s :<c-u>call enhanceOPM#AddTextObj('%s', 'a')<CR>", rhs, a:char)
    else
        silent! execute printf("onoremap <silent> i%s :<c-u>call enhanceOPM#AddTextObj('%s', 'i')<CR>", a:char, a:char)
        silent! execute printf("onoremap <silent> a%s :<c-u>call enhanceOPM#AddTextObj('%s', 'a')<CR>", a:char, a:char)
    endif
endf
