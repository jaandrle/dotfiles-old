#!/usr/bin/env nodejsscript
/* jshint esversion: 11,-W097, -W040, module: true, node: true, expr: true, undef: true *//* global echo, $, pipe, s, fetch, cyclicLoop */
const p_home= $.xdg.home`Applications/piper/`
const p_models= p_home+"models/"

$.api("", true)
.version("2023-05-31")
.describe([
	"This is a wrapper around the piper CLI.",
	"It allows you to get the list of available models, or to simplify `piper` callings.",
	"",
	"Visit: https://github.com/rhasspy/piper",
	"Original help:",
	...s.$().run`${p_home}piper --help`.stderr.split("\n").filter(Boolean).map(l=> "\t"+l)
])
.option("--models", "prints available models")
.option("--model, -m", "chooses voice model by it's index or by text search (full name)")
.option("--input_file, -I", "path to input text file (defaults to stdin)")
	.action(function main({
		models: is_models,
		model= 0,
		input_file,
		_,
		...pass
	}){
		if(is_models){
			models()
				.forEach(l=> echo(l));
			echo(helpTextModels("…for more models"))
			$.exit(0);
		}
		model= getModel(model);
		pass= Object.entries(pass)
			.map(([ name, value ])=> `${name.length > 1 ? "--" : "-"}${name} '${value}'`)
			.join(" ");
		const o= s.run(`echo ${text(input_file)} | ${p_home}piper --model ${model} ${pass}`);
		$.exit(o.code);
	})
.parse();

function text(input_file){
	const candidate= input_file ? s.cat(input_file).stdout : $.stdin.text();
	if(typeof candidate!=="string")
		$.error("Missing input text file or piped text. Use `--help` for more information.");
	return "'"+candidate.trim().replaceAll("\n", "\t — \t").replaceAll("'", "\"")+"'";
}
function getModel(identifier){
	const candidate= typeof identifier==="number" ?
		models()[identifier] :
		models().find(l=> l.includes(identifier));
	if(!candidate)
		$.error([
			`Model identifier '${identifier}' seems not to matching any existing model.`,
			"Try `--models` to see all available models."
		].join("\n"));
	return candidate.slice(candidate.indexOf(" ")+1);
}
function models(){
	const out= s.ls(`${p_models}*.onnx`)
		.map((l, n)=> `${n}: ${l}`);
	if(!out.length)
		$.error(helpTextModels("No available models."));
	return out;
}
function helpTextModels(...text_initial){
	return [
		...text_initial,
		"Visits https://github.com/rhasspy/piper",
		"and download/extract model(s) into "+p_models
	].join("\n");
}
