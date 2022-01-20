#!/usr/bin/env zx
/* jshint esversion: 8,-W097, -W040, node: true, expr: true, undef: true */
const version= "2022-01-19";
const { _: [ path, lang, ...query ], help, b: to_long }= argv;
if(!lang){
    console.log(`
    ${chalk.blue(path.slice(path.lastIndexOf("/")+1))}@${chalk.green(version)}
    This is just wrapper around 'trans' cli utility.
    _trans [lang|--help|-b] …another
        - 'lang' in form '2*' means from current to *.
          In form '*' means from * to current. * is for
          example 'en'/'de'/….
        - '--help': show this text
        - '-b': off '-b' parametrer

    Examples:
    '_trans 2en pes' → 'trans cs:en -b pes'
    '_trans en -b dog' → 'trans en:cs dog'
    `);
    process.exit(help ? 0 : 1);
}
if(!to_long) query.unshift('-b');
query.unshift(lang[0]==="2" ? lang.replace("2", "cs:") : ( lang.indexOf(":")!==-1 ? lang : lang+":cs" ));
$`trans ${query} | xclip -selection clipboard`;
