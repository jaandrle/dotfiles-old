#!/usr/bin/env zx
/* jshint esversion: 8,-W097, -W040, node: true, expr: true, undef: true */
const app= {
	name: path.basename(process.argv[2]),
	version: "2022-07-29",
	cmd: "~/.local/bin/himalaya",
	configs: os.homedir()+"/.config/himalaya/",
	modificator: "§"
};
const chars= { "&AOE-": "á", "&AWE-": "š", "&ARs-": "ě" };
let argv_arr= argvArr();

const quote= $.quote;
$.quote= arg=> arg===app.cmd ? app.cmd : quote(arg);
$.verbose= !!argv.verbose;

if("help"===argv_arr.toString().replaceAll("-", "")){ //#region
	echo([	`${app.name}@${app.version}`,
			`This is small wrapper around 'himalaya' fixing coding errors and provide better 'read'.`,
			"" ]);
	echo(await $`${app.cmd} --help`);
	process.exit(0); //#endregion
}
if("version"===argv_arr.toString().replaceAll("-", "")){//#region
	echo(`${app.name} ${app.version}`);
	echo(await $`${app.cmd} --version`);
	process.exit(0);//#endregion
}
if("completion,bash"===argv_arr.toString()){//#region
	const completion= await $`${app.cmd} ${argv_arr}`;
	console.log(completion.toString().replace("himalaya)", `himalaya|${app.name})`));
	console.log(`alias ${app.name}-inbox="§mail § | less -R -S"`);
	console.log(`complete -F _himalaya -o bashdefault -o default ${app.name}`);
	process.exit(0);//#endregion
}
if(argv_arr.indexOf(app.modificator)===-1){
	await $`${app.cmd} ${argv_arr}`
	.pipe(process.stdout);
	process.exit(0);
}
argv_arr= argv_arr.filter(str=> str!==app.modificator);
if(argv_arr.indexOf("read")!==-1){
	const email= os.tmpdir()+"/himalaya-read.eml";
	await $`${app.cmd} ${argv_arr} -h From -h Subject`
	.pipe(fs.createWriteStream(email));
	await $`vim ${email}`
	.pipe(process.stdout);
	process.exit(0);
}

const template_path= app.configs+"template-inbox.json";
if(!fs.existsSync(template_path)){
	echo(await $`${app.cmd}`);
	process.exit(0);
}
await Promise.all(JSON.parse(fs.readFileSync(template_path)).map(function(line){
	if(line.indexOf("himalaya")!==0)
		return Promise.resolve(chalk.reset("===\n")+chalk.magenta(line));
	return $`${app.cmd} ${line.slice(1)}`;
})).then(function(lines){
	lines.forEach(echo);
});
process.exit(0);

/** @param {string} str */
function echo(str){
	const strs= Array.isArray(str) ? str : (typeof str!=='string' ? str.toString() : str).trim().split("\n");
	return strs.forEach(function(line){
		let c= 0;
		line= line.trim().replace(new RegExp(`(${Object.keys(chars).join("|")})`, "g"), l=> ++c && chars[l]);
		const i= line.lastIndexOf("│");
		if(i>-1)
			line= line.slice(0, i) + " ".repeat(c*4) + line.slice(i);
		console.log(line);
	});
}
function argvArr(){
	const _chars= Object.entries(chars).reduce((acc, [ key, val ])=> Reflect.set(acc, val, key) && acc, {});
	return process.argv.slice(3).map(str=> str.replace(new RegExp(`(${Object.keys(_chars).join("|")})`, "g"), l=> _chars[l]));
}
// vim: set tabstop=4 shiftwidth=4 textwidth=250 noexpandtab ft=javascript :
// vim>60: set foldmethod=marker foldmarker=#region,#endregion :
