```
                  %%VERSION%%
                                    
                                    Autor: Bram Moolenaar a další
                               Modified by team+vim@tracker.debian.org
                     Vim je volně šiřitelný program s otevřeným zdrojovým kódem

                                   Pomozte chudým dětem v Ugandě!
                       podrobnější informace získáte pomocí :help iccf<Enter>
```

## Získání nápovědy
- `:help<Enter>`: Zobrazit nápovědu (nebo také `<F1>`, `:help __něco__<Enter>`, …)
- `:help version8<Enter>`: Zobrazit informace o této verzi
- `sh\`, `shs`, `shh<Enter>`: Zobrazit kombinace kláves začínající `\`, `s` a jiné zajímavé


## Jak ukončit VIM
- `:q<Enter>`: Ukončit program/okno (nebo také `:qa<Enter>`, `ZZ` a `ZQ` … viz `:help write-quit`)
- `:bd<Enter>`: Zavřít soubor (tzv. „buffer”)


## Rychlá navigace na této stránce
- `w`: Otevřít *sezení* (viz `:CLsessionLoad`), `W` zkratka pro vyfiltrování jen pracovních
- Otevřít soubor:
    - `o`: *dříve otevřený* (viz `:help oldfiles<Enter>`)
    - `e`: *prázdný*
    - `p`: *prázdný a vložit text ze systémové schránky*
- `m`: Seznam záložek (viz `:help mark-motions<Enter>`)
- `c`: Upravit tento soubor
- `P`: Rozbalit poznámky níže

<!--region Poznámky -->
## Poznámky
<!--endregion-->

## Náhodná část z konfiguračního souboru `.vimrc`
```vim %%VIMRC%%
```

<!--region Mapování -->
nnoremap <buffer><silent> e :bd<cr>
nnoremap <buffer><silent> p :bd<bar>normal "+p<cr>
nnoremap <buffer><silent> o :ALToldfiles<cr>
nnoremap <buffer> w :call feedkeys(':CLSESSIONload <tab>', 'tn')<cr>
nnoremap <buffer> W :call feedkeys(':CLSESSIONload work_<tab>', 'tn')<cr>
nnoremap <buffer><silent> m :marks<cr>
nnoremap <buffer> P /region<cr>za
nnoremap <buffer><silent> c :e ~/.vim/intro-template.md<cr>
<!--endregion-->
