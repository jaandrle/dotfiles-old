#!/usr/bin/env nodejsscript
/* jshint esversion: 11,-W097, -W040, module: true, node: true, expr: true, undef: true *//* global echo, $, pipe, s, fetch, cyclicLoop */
import { html2rss } from './html2rss.mjs';
/** @typedef {import('./html2rss.mjs').T_RSSITEM} T_RSSITEM */
html2rss($[1], $[2], articles)
.then(pipe( echo, $.exit.bind(null, 0)));
/**
 * @param {string} response
 * @returns {T_RSSITEM[]}
 * */
function articles(response){
	const links= Array.from(response.matchAll(/vcard__link" href="([^"]*)"/g)).map(pluckFound);
	const dates= Array.from(response.matchAll(/vcard__publish[^>]*>([^<]*)</g)).map(pluckFound).map(toISO);
	return Array.from(response.matchAll(/<h3[^>]*>([^<]*)</g))
		.map(pluckFound)
		.filter(Boolean)
		.map(function(title, i){ return { title, link: links[i], date: dates[i] }; });

	/** @param {string} date */
	function toISO(date){ return date.split(". ").reverse().map(d=> d.padStart(2, "0")).join("-")+"T00:00:00.000Z"; }
	function pluckFound([ _, found]){ return found; }
}
