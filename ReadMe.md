## enhanceOPM
enhanceOPM enables us to define our own text objects, and will automatically find the closest area distinguished by a text object.

it is similar to [targets.vim], but with less power. \
[targets.vim] is too flexible for me, and I personally believe that one line enhancement of vim's build-in operator-pending mappings is alreay enough.

## Install
- by [dein.vim] :
```vim
call dein#add('Why8n/enhanceOPM')
```

- by [vim-plug]
```vim
Plug 'Why8n/enhanceOPM'
```

## Usage
by default, enhanceOPM supports charaters `()`, `[]`, `<>`, `{}`, `*`, `,`.

you can define your own charaters like below:
```vim
" pair charaters
call enhanceOPM#EOPM('()')

" single charaters
call enhanceOPM#EOPM('@')
```
and now you can type `di(`,`da(`,`ci)`,`ca)`,`di@`,`da@` and other commands to see the effect. \
**notice**: make sure current line contains charaters like `(xxx)` and `@xxx@`

## Advanced Usage
you can define your own text objects:
```vim
onoremap in) :<c-u>call enhanceOPM#AddTextObj('()','i')<CR>
onoremap ar* :<c-u>call enhanceOPM#AddTextObj('*','a')<CR>
```
now you can type `din` or `dar*` to see the results.

more detail usage, please refer to [doc - enhanceOPM.txt][enhanceOPM.txt]



[targets.vim]:https://github.com/wellle/targets.vim

[dein.vim]:https://github.com/Shougo/dein.vim

[vim-plug]:https://github.com/junegunn/vim-plug

[enhanceOPM.txt]:https://github.com/Why8n/enhanceOPM/blob/main/doc/enhanceOPM.txt
