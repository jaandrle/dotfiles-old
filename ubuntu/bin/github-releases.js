#!/usr/bin/env node
/* jshint esversion: 8,-W097, -W040, node: true, expr: true, undef: true */
const /* dependencies */
    [ fs, readline, https, { spawn } ]= [ "fs", "readline", "https", "child_process" ].map(p=> require(p));
const /* helper for coloring console | main program params */
    colors= { e: "\x1b[38;2;252;76;76m", s: "\x1b[38;2;76;252;125m", w: "\x1b[33m", R: "\x1b[0m", y: "\x1b[38;2;200;190;90m", g: "\x1b[38;2;150;150;150m" },
    info= {
        name: __filename.slice(__filename.lastIndexOf("/")+1, __filename.lastIndexOf(".")),
        version: "1.1.1",
        description: "Helper for working with “packages” stored in GitHub releases.",
        config: `${__filename.slice(0, __filename.lastIndexOf("."))}.json`,
        folder: __filename.slice(0, __filename.lastIndexOf("/")+1),
        commands: [
            {
                cmd: "help", args: [ "--help", "-h" ],
                desc: "Shows this text"
            },
            {
                cmd: "config", args: [ "--config" ],
                desc: "Opens config file in terminal editor (defaults to vim)"
            },
            {
                cmd: "check", args: [ "--check", "-c" ],
                desc: "Shows/checks updates for registered packages"
            },
            {
                cmd: "update", args: [ "--update", "-u" ], param: "group",
                desc: "Installs lates versions of registered packages"
            },
            {
                cmd: "uninstall", args: [ "--uninstall", "-u" ], param: "package",
                desc: "Deletes downloaded file and moves package to the 'skip' group"
            },
            {
                cmd: "register", args: [ "--register", "--change" ], param: "package",
                desc: "Add package infos to internal list to be able installing/updating"
            },
            {
                cmd: "remove", args: [ "--remove" ], param: "package",
                desc: ([
                    "Uninstall package if needed (see `-u`)",
                    "And remove it from internal list (see `--config`)"
                ]).join(". ")
            }
        ],
        params: {
            group: ([
                "You can label each package to update only choosen one",
                "There are sereved options:",
                "  - '' (empty): these packages are includes in all groups",
                "  - 'all': in case of `--update` process all packages (except skipped)",
                "  - 'skip': these packages are “uninstalled”",
                "            No updates will be downloaded",
                "Group can be setted via '--register'"
            ]).join(". "),
            package: ([
                "Represents package identificator, it is in fact GitHub repository path",
                "So, it schould be in the form `username/repository`"
            ]).join(". ")
        }
    };
printMain();
const current= getCurrent(process.argv.slice(2));
(function main_(){
    const { cmd }= current.command;
    switch(cmd){
        case "help":        return Promise.resolve(printHelp());
        case "config":      return vim_(info.config);
    }
    const config= getConfig();
    switch(cmd){
        case "register":    return register_(config);
    }
    if(!config.packages)    return Promise.resolve("No packages yet!");
    switch(cmd){
        case "check":       return check_(config);
        case "update":      return update_(config);
        case "uninstall":
        case "remove":
                            return uninstall_(cmd, config);
    }
})()
.then(function(message){
    if(message)
        log(1, `Operation '${current.command.cmd}' successfull: @s_${message}`);
    process.exit();
})
.catch(error);

async function uninstall_(cmd, config){
    const progress= [
        [ "Deleting file", "not needed" ],
        [ "Check out from updates", "yes" ],
        [ "Remove from packages list", "no" ]
    ];
    const pkg_name= current.param;
    const pkg_index= config.packages.findIndex(({ repository })=> repository===pkg_name);
    if(pkg_index===-1) return "nothing to do (maybe typo)";

    const pkg= config.packages[pkg_index];
    const { downloads }= pkg;
    if(downloads&&fs.existsSync(downloads)){
        try{ fs.unlinkSync(downloads); progress[0][1]= "done"; }
        catch (_){ progress[0][1]= colors.e+"error, try manually – "+downloads; }
    }
    Reflect.deleteProperty(pkg, "last_update");
    Reflect.set(pkg, "group", "skip");
    progress[1][1]= "done";
    if(cmd!=="remove") return gotoEnd();

    const y= await promt_(`Are you realy want to remove package ${pkg.repository} (yes/no)`, "no");
    if(y!=="yes") return gotoEnd();

    config.packages.splice(pkg_index, 1);
    progress[2][1]= "done";
    return gotoEnd();

    function gotoEnd(){
        const o= progress.reduce((o, [ k, v ])=> Reflect.set(o, k, v)&&o, {});
        logSection("  ", pkg_name, o);
        save(config);
    }
}
function vim_(file){ return new Promise(function(resolve, reject){
    const cmd= spawn(process.env.EDITOR||"vim", [ file ], { stdio: 'inherit' });
    cmd.on('exit', e=> e ? reject("Editor error, try manually: "+file) : resolve("OK"));
});}
async function update_(config){
    const filter= current.param;
    const is_all= filter==="all";
    let updates= [];
    log(1, "Collecting packages to download:");
    for(const [
        i, { repository, version, last_update, group, file_name, exec, downloaded }
    ] of Object.entries(config.packages)){
        if(group==="skip") continue;
        if(!is_all&&group&&filter!==group) continue;

        const { tag_name, published_at, html_url, assets_url }= await githubRelease_(repository);
        const status= packageStatus(last_update, published_at);
        if(status!==3) continue;

        const assets= await downloadJSON_(repository, assets_url);
        if(!assets.length){
            console.log("  Nothing to download: Visit "+html_url);
            continue;
        }

        const options= assets.map(({ name, download_count, size })=>
            `${name} | size: ${Math.round(size/1048576)}MB | downloads: ${download_count}`);
        logSection("  ", " "+repository, {
            "Version": tag_name,
            "Url": html_url
        });
        logSection("   ", " Available assets:", options);
        const choose= await promt_("      Choose (empty for skip)", "");
        if(choose==="") continue;

        const { browser_download_url: url, name: remote_name, size }= assets[choose];
        updates.push({
            index: i,
            file_name, exec, downloaded,
            repository, version: tag_name, last_update: published_at,
            url, remote_name, size
        });
    }
    if(!updates.length){
        log(2, "No packages in "+`group ${filter} needs updates.`);
        return Promise.resolve("nothing to update");
    }
    log(1, "Downloading:");
    return applySequentially_(updates, async function(todo){
        const to= todo.file_name ? info.folder+todo.file_name : (
                  todo.downloaded ? todo.downloaded : info.folder+todo.remote_name);
        const d= await downloadFile_(to, todo);
        return Object.assign(todo, d);
    })
    .then(function(dones){
        log(1, "Finalizing:");
        let e= 0;
        for(const nth of dones){
            if(!nth.success){
                e+= 1;
                log(2, `${nth.repository}: @e_${nth.message}`);
                continue;
            }
            Object.assign(config.packages[nth.index], registerDownloads(nth));
        }
        save(config);
        const { length }= dones;
        const msg= `updated ${length-e} of ${length} packages.`;
        return e ? Promise.reject(msg) : Promise.resolve(msg);
    });
}
function registerDownloads({ repository, last_update, message: downloads, exec, version }){
    let msg= colors.s+"OK";
    if(exec==="yes"){
        try{ fs.chmodSync(downloads, 0o755); }
        catch(e){ msg= colors.e+"try manual `chmod+x` for '"+downloads+"'"; }
    }
    log(2, `${repository}: ${msg}`);
    return { last_update, downloads, version };
}
async function check_({ packages }){
    let updates= 0, skipped= 0;
    for(const { repository, name, version, last_update, group } of packages){
        const { tag_name, published_at }= await githubRelease_(repository);
        const status= packageStatus(last_update, published_at);
        updates+= status===3;
        const skip= group==="skip";
        skipped+= skip;
        log(2, `@g_${repository}: `+( !version ? "not installed" : packageStatusText(status, skip) ));
    }
    const u= updates-skipped;
    const s= skipped ? ` (inc. skipped: ${updates})` : "";
    return (!u ? "" : colors.w)+u+" update(s) available"+s;
}
async function register_(config){
    const { param: repository }= current;
    if(!Reflect.has(config, "packages")) Reflect.set(config, "packages", []);
    const packages= Reflect.get(config, "packages");
    let local_id= packages.findIndex(p=> p.repository===repository);
    if(local_id===-1)
        local_id= packages.push({ repository })-1;
    const local= config.packages[local_id];
    const remote= await githubRepo_(repository) || {};

    log(1, "Registering: "+repository);
    const spaces= "    ";
    local.name= await promt_(spaces+"Name", local.name || remote.name || "");
    if(!local.description) local.description= remote.description;
    logLines(2, [
        "@g_Group info:",
        "- you can update specific packages by using their group name",
        "- There some reserved options:",
        "  - '' (empty): will be included in all groups",
        "  - 'skip': will be always skipped"
    ]);
    local.group= await promt_(spaces+"Group", local.group || "");
    local.file_name= await promt_(spaces+"File Name", local.file_name || local.name.toLowerCase().replace(/\s/g, "-") || "");
    local.exec= await promt_(spaces+"Make executable (yes/no)", local.exec || "no");
    save(config);
    return `${repository}: saved`;
}
function packageStatusText(status, skip){
    const s= skip ? colors.R+"skipped – "+colors.g : "";
    switch(status){
        case 0: return s+"nothing to compare";
        case 1: return s+"@s_up-to-date";
        case 2: return s+"newer";
        case 3: return s+"@e_outdated/not instaled";
    }
}
function packageStatus(local, remote){
    if(!remote) return 0;
    if(!local) return 3;
    if(remote===local) return 1;
    return 2+(local<remote);
}
function logSection(spaces, name, data){
    console.log(spaces+name);
    for(const [ key, value ] of Object.entries(data))
        console.log(spaces.repeat(2)+colors.g+key+": "+value.replace(/@(\w)_/g, (_, m)=> colors[m])+colors.R);
}
function githubRelease_(repository){
    return downloadJSON_(repository, "https://api.github.com/repos/"+repository+"/releases")
    .then(data=> data.find(({ draft, published_at })=> !draft&&published_at) || {});
}
function githubRepo_(repository){ return downloadJSON_(repository, "https://api.github.com/repos/"+repository); }
function promt_(q, def){
    const rl= readline.createInterface({ input: process.stdin, output: process.stdout });
    return new Promise(function(resolve){
        rl.question(q+": ", a=> { rl.close(); resolve(a); });
        rl.write(def);
    });
}
function getConfig(){
    let config;
    try{ config= JSON.parse(fs.readFileSync(info.config)); }
    catch(e){ config= {}; log(1, "@w_Missing or corrupted config file. Creates empty one."); }
    return config;
}
function save(config){
    return fs.writeFileSync(info.config, JSON.stringify(config, null, "    "));
}
function getCurrent(args){
    let command, command_arg, param;
    const hasArg= arg=> ({ args })=> args.includes(arg);
    for(let i=0, { length }= args, arg; i<length; i++){
        arg= args[i];
        if(!command){
            command= info.commands.find(hasArg(arg));
            command_arg= arg;
            continue;
        }
        if(!command.param||typeof param!=="undefined")
            break;
        param= arg;
    }
    if(!command)
        command= { cmd: "help" };
    if(command.param&&typeof param==="undefined")
        return error(`Missign arguments for '${command_arg}'.`);
    return { command, param };
}
function downloadJSON_(repository, url){
    return downloadText_(url)
    .then(function(data){
        try{ return Promise.resolve(JSON.parse(data)); }
        catch(e){
            log(1, "Received data: "+data);
            log(1, "@e_"+e);
            return Promise.reject(`JSON from '${repository}' failed.`);
        }
    });
}
function downloadText_(url){
    return get_(url)
    .then(function(response){ return new Promise(function(resolve){
        let data= "";
        response.on("data", chunk=> data+= chunk);
        response.on("end", ()=> resolve(data));
    }); });
}
function downloadFile_(to, { url, repository, size }){
    const file= fs.createWriteStream(to);
    return get_(url)
    .then(r=> get_(r.headers.location))
    .then(function(response){ return new Promise(function(resolve){
        let progress= 0, pc_prev= 0, avg= 0;
        const start= new Date();
        const i= setInterval(function(){
            readline.clearLine(process.stdout);
            const pc= (100*progress/size).toFixed(2);
            if(!pc_prev) pc_prev= pc;
            else {
                avg= ((100-pc)/(60*(pc-pc_prev))).toFixed(2);
                pc_prev= 0;
            }
            const running= ((new Date()-start)/60000).toFixed(2);
            log(2, repository+": "+pc+"%"+` (end in ~${avg} mins, running ${running} mins)`);
            readline.moveCursor(process.stdout, 0, -1);
        }, 500);
        response.on('data', function(chunk){
            file.write(chunk);
            progress+= chunk.length;
        });
        response.on('end', function(){
            clearInterval(i);
            readline.clearLine(process.stdout);
            log(2, repository+": @s_OK");
            file.close(()=> resolve({ success: 1, message: to })); /* close() is async, call cb after close completes. */
        });
    }); })
    .catch(({ message })=> {
        fs.unlink(to); // Delete the file async. (But we don't check the result)
        return { success: 0, message };
    });
}
function get_(url){ return new Promise(function(resolve, reject){
    https.get(
        url,
        { headers: { 'Cache-Control': 'no-cache', 'User-Agent': 'node' } },
        resolve
    ).on("error", reject);
});}
function applySequentially_(input, pF){
    const data= [];
    const p= pF(input[0]);
    const tie= nth=> result_mth=> ( data.push(result_mth), pF(input[nth]) );
    for(let i= 1, { length }= input; i<length; i++)
        p.then(tie(i));
    return p.then(o=> (data.push(o), data));
}
function error(message){
    const help_text= `@w_See help using '${info.commands[0].args[0]}'.`;
    log(1, `@e_Error: ${message} ${help_text}`);
    return process.exit(1);
}
function printMain(){
    const { name, version, description }= info;
    log(1, `@w_${name}@${version}`);
    log(1, description);
    const cmds= info.commands.map(({args})=> args[0].replace("--", "")).join(", ");
    log(1, `@w_Usage: ${name} --[cmd] [param]`);
    log(2, `…cmd: ${cmds}`);
    log(2, "…param: Based on cmd\n");
}
function printHelp(){
    log(1, "@s_Help:");
    log(2, "Commands:");
    info.commands.forEach(({ args, param, desc })=> {
        const args_text= args.join("|");
        param= param ? " "+param : "";
        log(3, `@g_${args_text}@R_${param}`);
        logLines(4, desc);
    });
    log(2, "Params:");
    for(const [ param, desc ] of Object.entries(info.params)){
        log(3, `@g_${param}`);
        logLines(4, desc);
    }
}
function log(tab, text){
    return console.log("  ".repeat(tab)+text.replace(/@(\w)_/g, (_, m)=> colors[m])+colors.R);
}
function logLines(tab, multiline_text){
    if(!Array.isArray(multiline_text)) multiline_text= multiline_text.split(/(?<=\.) /g);
    return log(tab, multiline_text.join("\n"+"  ".repeat(tab)));
}
