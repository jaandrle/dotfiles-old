#!/usr/bin/env nodejsscript
/* jshint esversion: 8,-W097, -W040, node: true, expr: true, undef: true *//* global echo, $, pipe, s, style, fetch, cyclicLoop */
$.api("<...query_array>")
.version("v2022-09-23")
.describe([
	"This is just redirection to [WolframAlpha](https://www.wolframalpha.com/) site.",
	"Use the same expressions as on web page."
])
.example("linear fit {1.3, 2.2},{2.1, 5.8},{3.7, 10.2},{4.2, 11.8}")
.example("polynomial fit {1,2},{2,3.1},{3,3.9}")
.example("Fit[{{1,2},{2,3.1},{3,3.9}}, {1,x}, x]")
.action(function main(_, { _: query_array }){
	echo("Opening:");
	echo("https://www.wolframalpha.com/input/?i="+encodeURI(query_array.join(" ")).replace(/\+/g, '%2B'))
	.xargs(s.runA, "exo-open --launch WebBrowser {}")
	.then($.exit.bind(null, 0)).catch($.exit.bind(null, 1));
})
.parse((()=> ( process.argv.splice(2, 0, 'skip'), process.argv ))());
