#!/usr/bin/env zx
/* jshint esversion: 8,-W097, -W040, node: true, expr: true, undef: true */
const version= "2022-01-19";
const { _: [ path, lang, ...query ], help, b: to_long, c: to_clipboard }= argv;
const this_name= path.slice(path.lastIndexOf("/")+1);
if(!lang){
    console.log(`
    ${chalk.blue(this_name)}@${chalk.green(version)}
    This is just wrapper around 'trans' cli utility.
    ${this_name} [lang|--help|-b] …another
        - 'lang' in form '2*' means from current to *.
          In form '*' means from * to current. * is for
          example 'en'/'de'/….
        - '--help': show this text
        - '-b': off '-b' parametrer
        - '-c': redirect into clipboard ('| xclip -selection clipboard')

    Examples:
    '${this_name} 2en pes' → 'trans cs:en -b pes'
    '${this_name} en -b dog' → 'trans en:cs dog'
    `);
    process.exit(help ? 0 : 1);
}
if(!to_long) query.unshift('-b');
query.unshift(lang[0]==="2" ? lang.replace("2", "cs:") : ( lang.indexOf(":")!==-1 ? lang : lang+":cs" ));
query.push('-no-ansi');

if(to_clipboard) process.exit(await $`trans ${query} | xclip -selection clipboard 2>1 > /dev/null`);

$.verbose= false;
$`trans ${query}`.pipe(process.stdout)
