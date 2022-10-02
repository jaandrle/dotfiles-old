#!/usr/bin/env nodejsscript
/* jshint esversion: 11,-W097, -W040, module: true, node: true, expr: true, undef: true *//* global echo, exit, cli, pipe, s, style, fetch, cyclicLoop, xdg, $ */
import { basename } from "path";
const app= {
	name: basename(process.argv[1]),
	version: "2022-09-28",
	cmd: cli.xdg.home`.local/bin/himalaya`,
	configs: cli.xdg.config`himalaya/`,
	modificator: "§"
};
const chars= { "&AOE-": "á", "&AWE-": "š", "&ARs-": "ě" };
let argv_arr= argvArr();

if("help"===argv_arr.toString().replaceAll("-", "")){ //#region
	echo([	`${app.name}@${app.version}`,
			`This is small wrapper around 'himalaya' fixing coding errors and provide better 'read'. (Use § for calling himalaya directly)`,
			"" ].join("\n"));
	s.run(app.cmd+" --help");
	exit(0); //#endregion
}
if("version"===argv_arr.toString().replaceAll("-", "")){//#region
	echo(`${app.name} ${app.version}`);
	s.run(app.cmd+" --version");
	process.exit(0);//#endregion
}
if("completion,bash"===argv_arr.toString()){//#region
	const completion= s.run(app.cmd+" ::argv_arr::", { argv_arr });
	echo(completion.toString().replace("himalaya)", `himalaya|${app.name})`));
	echo(`alias ${app.name}-inbox="§mail § | less -R -S"`);
	echo(`complete -F _himalaya -o bashdefault -o default ${app.name}`);
	exit(0);//#endregion
}
(async function main(){
	if(argv_arr.indexOf(app.modificator)!==-1) await runH(argv_arr.filter(l=> l!==app.modificator));
	
	argv_arr= argv_arr.filter(str=> str!==app.modificator);
	if(argv_arr.indexOf("list")!==-1){
		argv_arr.push("-w", process.stdout.columns);
		await runH(argv_arr);
	}
	if(argv_arr.indexOf("read")!==-1){
		const email= cli.xdg.temp`/himalaya-read.eml`;
		argv_arr.push("-h", "From", "-h", "Subject");
		await s.$().runA(app.cmd+" ::argv_arr::", { argv_arr }).pipe(s=> s.to(email));
		await s.runA`vim ${email}`.pipe(process.stdout);
		exit(0);
	}
	
	if(argv_arr[0] && argv_arr[0]!=="--rofi") await runH(argv_arr);

	const template_path= app.configs+"template-inbox.json";
	if(!s.test("-f", template_path)) await runH([]);

	await pipe(
		f=> s.cat(f).xargs(JSON.parse),
		argv_arr.indexOf('--rofi')===-1 ? templateRead : templateRofi,
		a=> Promise.all(a),
		p=> p.then(l=> echo(l.join("\n")))
	)(template_path);
	exit(0);
})();

function templateRofi(lines){
	return lines.filter(line=> line.type!=="text")
	.map(line=>
		s.$().runA(app.cmd+" ::value:: -w 120", line)
		.then(data=> data.toString().split("\n")
			.filter(l=> l)
			.map(line=> line.replaceAll("✷ ", "* "))
			.map(line_result=> line_result+" │ "+line.label)
			.join("\n"))
	);
}
function templateRead(lines){
	argv_arr.push("-w", process.stdout.columns);
	return lines.map(line=> line.type==="text" ?
		Promise.resolve(style.reset("===\n")+style.magenta(line.value)) :
		s.$().runA(app.cmd+" ::value:: ::argv_arr::", { value: line.value, argv_arr })
	);
}

function argvArr(){
	const _chars= Object.entries(chars).reduce((acc, [ key, val ])=> Reflect.set(acc, val, key) && acc, {});
	return process.argv.slice(2).map(str=> str.replace(new RegExp(`(${Object.keys(_chars).join("|")})`, "g"), l=> _chars[l]));
}
async function runH(args){
	const result= await s.runA(app.cmd+" ::args::", { args });
	exit(result.exitCode);
}
// vim: set tabstop=4 shiftwidth=4 textwidth=250 noexpandtab ft=javascript :
// vim>60: set foldmethod=marker foldmarker=#region,#endregion :
