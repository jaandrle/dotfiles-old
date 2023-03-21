#!/usr/bin/env nodejsscript
/* jshint esversion: 11,-W097, -W040, module: true, node: true, expr: true, undef: true *//* global echo, $, pipe, s, fetch, cyclicLoop */
$.is_fatal= true;
const css= echo.css`
	.code, .url{ color: lightblue; }
	.code::before, .code::after{ content: "\`"; }
`;
testRequirements();
$.api()
	.version("2023-03-21")
	.describe([
		"Small utility to find out FTP url with credentials using Bitwarden CLI.",
		echo.format("The idea is to use saved login %cusername%c, %cpassword%c and %curl%c.",
			css.code, css.unset, css.code, css.unset, css.code, css.unset)
	])
	.command("get [name]", "Get url with credentials.")
		.alias("item")
		.option("--copy", echo.format("Uses %cxclip -selection clipboard%c.", css.code))
	.action(get)
	.command("list", echo.format("List all %cftp-*%c.", css.code))
		.option("--json", "Print output in JSON format.")
	.action(list)
	.parse();

async function get(name, { copy: is_copy= false }){
	if(!name)
		name= await $.read({
			"-p": "Name",
			completions: list({ is_internal: true }).map(o=> o.name)
		});
	const item= s.$().run`bw get item ${name}`;
	if(!item.trim())
		$.error(`No record found for ${name}.`);
	
	const { uris, username, password }= item
		.xargs(JSON.parse)
		.login;
	const url= urlFromUris(uris).replace('://', `://${username}:${password}@`);
	if(!is_copy){
		echo(url);
		$.exit(0);
	}
	s.echo(url).run`xclip -selection clipboard 2>1 > /dev/null`;
	$.exit(0);
}
function list({ json= false, is_internal= false }){
	const list= s.$().run`bw list items --search="ftp"`
		.xargs(JSON.parse)
		.filter(o=> o.name.startsWith("ftp-"))
		.map(({ name, note, login: { uris } })=> ({ name, url: urlFromUris(uris), note }))
		.filter(o=> o.url);
	if(is_internal)
		return list;
	if(json)
		$.exit(0, echo(JSON.stringify(list)));

	list.forEach(pipe(
		line=> echo.format(line),
		t=> t.replaceAll("\n", " ").slice(2, -2),
		echo
	));
	$.exit(0);
}

function urlFromUris(uris){ return uris.find(o=> o.uri)?.uri; }

function testRequirements(){
	if(!s.which("bw"))
		$.error([
			echo.format("The %cbw%c utility has not been found.", css.code),
			echo.format("Please install it using %cnpm i @bitwarden/cli --location=global%c.", css.code),
			echo.format("Respectively, follow the instructions at %chttps://github.com/bitwarden/clients/tree/master/apps/cli", css.url)
		].join("\n"));
}
// vim: set tabstop=4 shiftwidth=4 textwidth=250 noexpandtab :
// vim>60: set foldmethod=indent foldlevel=1 foldnestmax=2:
