#!/usr/bin/env nodejsscript
/* jshint esversion: 8,-W097, -W040, node: true, expr: true, undef: true *//* global echo, exit, cli, pipe, s, style, fetch, cyclicLoop */
cli.api("<lang>")
.version("2022-09-23")
.describe("This is just wrapper around 'trans' cli utility.")
.option("-b", "Turn off '-b' parametrer for 'trans' which is give by this script.")
.option("-c", "Redirect into clipboard ('| xclip -selection clipboard')")
.example("2en pes → 'trans cs:en -b pes'")
.example("en -b dog → 'trans en:cs dog'")
.action(function main(lang, { _: query, c: to_clipboard, b: to_long }){
	query= [ `"${query.join(" ").replaceAll('"', '\\"')}"` ];
	if(!to_long) query.unshift('-b');
	query.unshift(lang[0]==="2" ? lang.replace("2", "cs:") : ( lang.indexOf(":")!==-1 ? lang : lang+":cs" ));
	query.push('-no-ansi');
	
	const result= s.$().run("trans "+query.join(" "));
	if(!to_clipboard) return echo(result.toString()); 
	result.runA("xclip -selection clipboard 2> /dev/null 1> /dev/null")
	.then(exit.bind(null, 0)).catch(exit.bind(null, 1));
})
.parse(process.argv);
