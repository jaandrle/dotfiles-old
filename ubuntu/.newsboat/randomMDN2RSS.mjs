#!/usr/bin/env nodejsscript
/* jshint esversion: 11,-W097, -W040, module: true, node: true, expr: true, undef: true *//* global echo, $, pipe, s, fetch, cyclicLoop */
const url_sitemap= 'https://developer.mozilla.org/sitemaps/en-us/sitemap.xml.gz';
const url_web= 'https://developer.mozilla.org/en-US/docs/Web';

(async ()=> {
	const webDocUrls= await getWebDocUrls();
	const list= [];
	while(list.length < 10){
		const candidate= await article(webDocUrls[Math.floor(webDocUrls.length * Math.random())]);
		if(!candidate.title) continue;
		list.push(candidate);
	}
	const articles_rss= list.map(function({ title, description, date, link, guid }){
		return [
			"<item>",
				"<title>"+title+"</title>",
				"<description>"+description+"</description>",
				"<link>"+link+"</link>",
				"<guid>"+guid+"</guid>",
				"<updated>"+date+"</updated>",
			"</item>"
		].join("\n");
	});
	return [
		`<?xml version="1.0" encoding="UTF-8" ?>`,
		`<rss version="2.0">`,
		"<channel>",
		`<title>🦖 Random MDN</title>`,
		`<link>${url_web}</link>`,
		...articles_rss,
		"</channel>",
		"</rss>"
	].forEach(l=> echo(l));
})();

async function getWebDocUrls(){
	const sitemap= await fetch(url_sitemap, {
		responseType: 'buffer',
		headers: {
		'accept-encoding': 'gzip',
		},
	}).then(res=> res.text());

	return Array.from(sitemap.matchAll(/<loc>(.*?)<\/loc>/g))
		.map(([ _, url ])=> url)
		.filter(onlyAllowWebUrls);
};
async function article(link){
	const doc= await fetch(link).then(res=> res.text());
	// to not rely on exact words this matches the deprecation container
	if(/class="notecard deprecated"/.test(doc)) return {};
	
	const title= extractByRegexp(doc, /<h1>(.*?)<\/h1>/i);
	if(!title) return {};

	const inside_q= "(([^\"]|(?<=\\\\)\")*)";
	return {
		description: extractByRegexp(doc, new RegExp(`<meta name="description" content="${inside_q}"`, "i")) || "",
		date: extractByRegexp(doc, new RegExp(`<time datetime="${inside_q}">`, "i")) || "",
		guid: extractByRegexp(doc, new RegExp(`<a href="https://github.com/mdn/content/edit/main/files/${inside_q}"`, "i")) || "",
		title, link
	};
};

function extractByRegexp(str, regexp){
	const candidate= str.match(regexp);
	if(!candidate) return null;
	return candidate[1];
}
function onlyAllowWebUrls(url){ return url.startsWith(url_web); }
