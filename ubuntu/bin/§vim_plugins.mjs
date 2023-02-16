#!/usr/bin/env nodejsscript
/* jshint esversion: 11,-W097, -W040, module: true, node: true, expr: true, undef: true *//* global echo, $, pipe, s, fetch, cyclicLoop */
const dirs= { vim_root: $.xdg.home`.vim` };
Object.assign(dirs, {
	pack: dirs.vim_root+"/pack/",
	bundle: dirs.vim_root+"/bundle/",
	one_files: dirs.vim_root+"/bundle/__one_files/plugin/" });
const file_one_file= dirs.bundle+".one_file";
const runResToArr= pipe( s.$().run, ({ stderr, stdout })=> stdout+stderr, o=> o.split("\n"));
const css= echo.css`
	.code{ color: yellow; }
	.code::before, .code::after{ content: "\`"; }
	.url{ color: lightblue; }
`;

$.api()
.version("2023-02-14")
.describe([
	"Utility for managing vim plugins native way. It uses two types:",
	`- “old” way (${f("bundle", css.code)}): inspiration from ${f("https://shapeshed.com/vim-packages/", css.url)}`,
	`- vim8 native package managing (${f("pack", css.code)}): see for example ${f("https://shapeshed.com/vim-packages/", css.url)}`
])
.command("add <type> <url>", [
	"Add new package.",
	`Use ${f("bundle", css.code )}/${f("pack", css.code)} to specify the package ${f("type", css.code)}.`,
	`The ${f("url", css.url)} should be a URL to the script itself or url of the git repository or github repository in the form of ${f("username/reponame", css.url)}.`
])
	.alias("a")
	.alias("install")
	.option("--target, -t [target]", `In case of ${f("pack", css.code)} type, specify the target sub-directory (typically/defaults ${f("start", css.code)}).`)
	.action(function(type, url, { target }){
		switch(type){
			case "bundle": return addBundle(url);
			case "pack": return addPack(url, target);
		}
		echo("Nothing todo, check given arguments (compare to `--help`):", { type, url });
		$.exit(1);
	})
.command("list", "List all plugins paths/url/… (based on option).")
	.alias("ls")
	.option("--type, -t [type]", `Defaults to list of paths (${f("paths", css.code)}). Use ${f("repos", css.code)} to show plugins origin.`)
	.example("list")
	.example("list --type paths")
	.example("list --type repos")
	.action(actionList)
.command("export", "List all plugins in the form that can be imported by this Utility.")
	.action(actionList.bind(null, { format: "json" }))
.command("status", "Loops through all installed plugins and shows overall status.")
	.action(actionStatus)
.command("update", "Loops through all installed plugins and updates them.")
	.action(actionUpdate)
.parse();

function addBundle(url){
	const is_onefile= url.endsWith(".vim");
	if(!is_onefile)
		url= gitUrl(url);
}
function addPack(url, target= "start"){
	url= gitUrl(url);
}
function gitUrl(url_candidate){
	if(url_candidate.endsWith(".git"))
		return url_candidate;
	return "git@github.com:"+url_candidate;
}
async function actionUpdate(){
	const css= echo.css`
		.success{ color: lightgreen; }
		.success::before{ content: "✓ "; }
	`;
	updateRepo(dirs.bundle, getBundle());
	const todo= getOneFilesUrls();
	const progress= echoProgress(todo.length, "Downloaded one-file plugins");
	await Promise.all(todo.map(function(url, i){
		return fetch(url).then(r=> {
			progress.update(i, url);
			return r.text();
		}).then(f=> s.echo(f).to(dirs.one_files+fileName(url)));
	}));
	echo("One-file plugin(s) updated.");
	s.cd(dirs.bundle).$().run`git commit -m "Update"`;
	updateRepo(dirs.pack, getPack());

	$.exit(0);

	function updateRepo(dir, paths){
		echo(dir);
		const progress= echoProgress(paths.length, "Pulling");
		const todo= paths.map(function(p, i){
			progress.update(i, p);
			return pull(p);
		}).filter(isUpToDate);
		if(!todo.length)
			return echo("%cAll up-to-date!", css.success);
		todo.forEach(([ p, result ])=> echo("%c"+p+"\n", css.success, result.join("\n")));
	}
	function pull(p){
		s.cd(p);
		return [ p, runResToArr("git pull") ];
	}
	function isUpToDate([ _, result ]){
		return result[0]===" Already up-to-date.";
	}
}
function actionList({ type= "paths" }){
	if("paths"===type){
		echo(dirs.bundle);
		getOneFiles().forEach(echoPath);
		getBundle().forEach(echoPath);
		
		echo(dirs.pack);
		getPack().forEach(echoPath);
		$.exit(0);
	}
	const progress= echoProgress(3, "Collecting plugins urls");
	progress.update(0, dirs.bundle);
	const urls_bundle= getBundle().map(getRepo);
	progress.update(1, dirs.bundle);
	const urls_onefiles= getOneFilesUrls();
	progress.update(2, dirs.pack);
	const urls_pack= getPack().map(getRepo);
	
	if("repos"===type){
		const echoUrl= u=> echo(f(u, css.url));
		echo(dirs.bundle);
		urls_bundle.forEach(echoUrl);
		echo(dirs.bundle+".one_file");
		urls_onefiles.forEach(echoUrl);
		echo(dirs.pack);
		urls_pack.forEach(echoUrl);
	}
	if("json"===type){
		const o= {};
		o.bundle= urls_bundle;
		o.one_files= urls_onefiles;
		o.pack= urls_pack;
		echo(JSON.stringify(o));
	}
	$.exit(0);

	function getRepo(p){ s.cd(p); return runResToArr("git remote -v")[0].split(/\s+/g)[1]; }
}
function actionStatus(){
	const css= echo.css`
		.success { color: lightgreen; }
		.success::before { content: "✓ "; }
	`;
	check(dirs.bundle, getBundle());
	echo("Onefiles plugins are not supported yet");
	check(dirs.pack, getPack());
	$.exit(0);

	function check(root, repos){
		echo(root);
		const progress= echoProgress(repos.length);
		const results= repos.flatMap(function(p, i){
			progress.update(i, p);
			s.cd(p);
			const result= runResToArr("git fetch --dry-run --verbose")
				.filter(l=> !l ? false : l.startsWith("From") || (!l.startsWith(" = [up-to-date]") && !l.startsWith("POST") ));
			if(result.length===1) return [];
			return [ [ p, result.join("\n") ] ];
		});
		if(!results.length)
			return echo("%cup-to-date", css.success);
		results.forEach(([ p, l ])=> {
			echoPath(p);
			echo(l);
		});
	}
}

import { relative } from 'node:path';
function echoPath(path){ return echo(formatPath(path)); }
function formatPath(path){
	const type= path.startsWith(dirs.bundle) ? "bundle" : "pack";
	return echo.format("%c"+relative(dirs[type], path), "color:lightblue");
}
function echoProgress(length, message_start= "Working"){
	if($.isFIFO(1)) return { update(){} };
	
	const css= echo.css`
		.progress { color: lightblue; }
	`;
	echo.use("-R", `${message_start} (%c0/${length}%c)`, css.progress);
	return {
		update(i, status){
			const s= status ? `: ${status}` : "";
			return echo.use("-R", `${message_start} (%c${i+1}/${length}%c)${s}`, css.progress);
		}
	};
}

function getPack(){ return s.ls(dirs.pack).flatMap(f=> s.find(dirs.pack+f+"/start/*/")[0]); }
function getBundle(){ return s.cd(dirs.bundle).grep("path", ".gitmodules").split("\n").filter(Boolean).map(l=> dirs.bundle+l.split(" = ")[1]); }
function getOneFiles(){ return s.find(dirs.one_files+"*"); }
function getOneFilesUrls(){ return s.cat(file_one_file).split("\n").filter(Boolean); }

function fileName(url){ return url.split("/").pop(); }
/** Quick formating of one piece of text. */
function f(text, css){ return echo.format("%c"+text, css); }
