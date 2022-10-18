#!/usr/bin/env nodejsscript
/* jshint esversion: 11,-W097, -W040, module: true, node: true, expr: true, undef: true *//* global echo, exit, cli, pipe, s, style, fetch, cyclicLoop */
import { join as pathJoin } from "path";
import { platform } from "process";
const config_path= cli.xdg.data`package_global.json`;

cli.api("[name]", true)
.version("2022-10-06")
.describe([
	"Release cordova app with saved data in: "+config_path+".",
	"This should be JSON file with `cordova_keys_store` key/object:",
	`{"cordova_keys_store": { "NAME": { "path": "", "password": "", "alias": "" } }}`,
	"You can lists all saved options (NAME), when you run without arguments." ])
.option("--noclear", "Skipping cleaning existing apk files.")
.action(function main(name, { noclear }){
	if(!name){
		echo("Available options:");
		pipe(getConfig, Object.keys, a=> "- "+a.join("\n- "), echo)();
		exit(0);
	}
	const /* runtime arguments and cwd */
		{ path, password, alias }= getConfigFor(name),
		cwd= process.cwd(),
		platform_android= toDirPath( cwd, "platforms", "android" ),
		platform_build= !s.test("-e", toDirPath(platform_android, "app")) ? toDirPath(platform_android, "build") : toDirPath(platform_android, "app", "build"),
		apk_dir= toDirPath(platform_build, "outputs", "apk"),
		key_path= pathJoin(cwd, "keystore.jks"),
		process_clear= !noclear && !s.test("-e", toDirPath(platform_android, "app"));
	
	cli.configAssign({ verbose: true, fatal: true });
	if(process_clear) s.rm("-Rf", apk_dir+"*");
	s.cp(path, key_path);
	s.run("cordova" + ( platform==="win32" ? ".cmd" : "" ) + " ::args::",
		{ args: [ "build", "--release", "android", "--",'--keystore=keystore.jks', "--storePassword="+password, "--password="+password, "--alias="+alias ] });
	s.rm(key_path);// cordova si to uklada a uz potom bez nej nelze buildit vubec
	s.rm(platform_android+"release-signing.properties");
	exit(0);
})
.parse(process.argv);

function toDirPath(...path){ return pathJoin(...path)+"/"; }
function getConfigFor(name){
	const config= getConfig();
	if(Object.hasOwn(config, name))
		return config[name];

	cli.error(`Name '${name}' not found, use one of: `+Object.keys(config));
}
function getConfig(){
	if(!s.test("-f", config_path))
		cli.error("No config file found! Tested file path: "+config_path);
	try{
		const config= s.cat(config_path).xargs(JSON.parse).cordova_keys_store;
		if(!Object.keys(config).length) throw new Error();
		return config;
	} catch(e){
		cli.error("Unsupported config file: "+config_path+"! Use `--help` for more information.");
	}
}
