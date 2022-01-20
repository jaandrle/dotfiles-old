#!/usr/bin/env zx
/* jshint esversion: 8,-W097, -W040, node: true, expr: true, undef: true */
const { _: [ path, ...query_array ], help }= argv;
if(help){
    console.log(`
    ${chalk.blue(path.slice(path.lastIndexOf("/")+1))}@${chalk.green("v2022-01-13")}
    This is just redirection to [WolframAlpha](https://www.wolframalpha.com/) site.
    Use the same expressions as on web page.
    
    Examples:
        linear fit {1.3, 2.2},{2.1, 5.8},{3.7, 10.2},{4.2, 11.8}
        polynomial fit {1,2},{2,3.1},{3,3.9}
        Fit[{{1,2},{2,3.1},{3,3.9}}, {1,x}, x]
        plot 0.95 x + 1.1
    `);
    process.exit(0);
}
const url= "https://www.wolframalpha.com/input/?i="+encodeURI(query_array.join(" "));
$`exo-open --launch WebBrowser ${url}`;
