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
    while pos >= 0
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
            if pairLeftCount ==? 0
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

    while pos >= 0
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



fun! enhanceOPM#AddTextObj(char, range) abort
    " let [vStart, vEnd] = s:backupVisualSelectionArea()

    if len(a:char) ==? 2
        let [prePos, postPos] = s:searchPairChar(utils#getChar(a:char, 0), utils#getChar(a:char, 1))
    elseif len(a:char) ==? 1
        let [prePos, postPos] = s:searchSingleChar(a:char)
    else
        echoerr a:char.' is not supported!'
        return
    endif

    if exists('l:prePos') && exists('l:postPos')
        if prePos[2] < postPos[2]
            let offset = postPos[2] - prePos[2]
            if a:range ==? 'a'
                call setpos('.', prePos)
                execute printf("normal! v%sl", offset)
            else
                if offset ==? 1
                    return
                elseif offset ==? 2
                    let offset = 1
                else
                    let offset = postPos[2] - prePos[2] - 2
                endif
                let prePos[2] += 1
                call setpos('.', prePos)
                execute printf("normal! v%sl", offset)
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


