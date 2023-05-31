#!/usr/bin/env nodejsscript
/* jshint esversion: 11,-W097, -W040, module: true, node: true, expr: true, undef: true *//* global echo, $, pipe, s, fetch, cyclicLoop */
/**
 * @typedef T_RSSITEM
 * @type {{ title: string, link: string, date: string }}
 * */
/**
 * @param {string} title
 * @param {string} url
 * @param {(response: string)=> T_RSSITEM[]} parseItems
 * @returns {Promise<string>}
 * */
export function html2rss(title, url, parseItems){
	return fetch(url)
	.then(response=> response.text())
	.then(pipe( parseItems, toRSS ));
	
	function toRSS(items){
		const articles_rss= items.map(function({ title, date, link }){
			return [
				"<item>",
					"<title>"+title+"</title>",
					"<link>"+link+"</link>",
					"<updated>"+date+"</updated>",
				"</item>"
			].join("\n");
		});
		return [
			`<?xml version="1.0" encoding="UTF-8" ?>`,
			`<rss version="2.0">`,
			"<channel>",
			`<title>${title}</title>`,
			`<link>${url}</link>`,
			...articles_rss,
			"</channel>",
			"</rss>"
		].join("\n");
	}
}
