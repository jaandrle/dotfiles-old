#!/usr/bin/env node
import { readFileSync, writeFileSync, createWriteStream } from "fs";
import { get } from "https";
import { homedir } from "os";

const url_main= "https://www.bing.com";
const folder= homedir()+"/Obrázky/Bing Image Of The Day/";

get_(url_main+"/HPImageArchive.aspx?format=js&idx=0&n=2&mkt=cs-CZ")
.then(res=> {
    let body= "";
    res.on("data", chunk=> body+= chunk);
    res.on("end", ()=> pipe(data, update)(body));
})
.catch(e=> console.error(String(e)));

function update(data){
    if(data===null) return false;
    const { url, copyright }= data;
    Promise.allSettled(data.map(({ url, copyright }, id)=> getImage_(url, id ? "prev" : "now", copyright)))
    .then(res=> {
        let template= readFileSync(folder+"index_template.html").toString();
        res[0].status
        writeFileSync(folder+"index.html", res.reduce((out, { status, value })=> status==="rejected" ? out : out.replace(`::${value.name}::`, value.description), template));
    })
    .catch(e=> console.error(String(e)));
}
function getImage_(url, name, description){
    return get_(url_main+url)
    .then(res=> {
        const fs= createWriteStream(folder+name+'.jpg');
        res.pipe(fs);
        return new Promise(res=> fs.on("finish", ()=> {
            fs.close();
            res({ name, description });
        }));
    });
}
function data(body){
    try   { return JSON.parse(body).images; }
    catch { return null; }
}
function get_(url){ return new Promise(function(res,rej){ get(url, res).on("error", rej); }); }
function pipe(...f){ return Array.prototype.reduce.bind(f, (acc, f)=> f(acc)); }
