#!/usr/bin/env node
/* jshint esversion: 11,-W097, -W040, node: true, expr: true, undef: true */
import { get, request } from "https";
import { clearLine, moveCursor } from "readline";
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "fs";
import { createInterface } from "readline";
import { execFileSync } from "child_process";

const alias_join= "<%space%>";
const { script_name, path, Authorization, argvs }= scriptsInputs();
const { isTTY }= process.stdout;
const isTCS= /-256(color)?$/i.test(process.env.TERM);
const user_= prepareUser();
const opt_fields_tasks_mem= [ "memberships.project.name", "memberships.section.name" ];
const opt_fields_tasks= [ "name", ...opt_fields_tasks_mem, "modified_at", "num_subtasks", "custom_fields", "permalink_url", "tags.name", "tags.gid" ];
(async function main_(cmd= "list"){
    if("completion_bash"===cmd) return completion_bash();
    if("auth"===cmd) return auth_();
    if("alias"===cmd) return alias("_", argvs);
    if("abbreviate"===cmd) return abbreviate(argvs);
    if("api"===cmd) return api_();

    if("marks"===cmd) return marks_();
    
    if("list"!==cmd) return Promise.reject(`Unknown command '${cmd}'`);
    const type= argvs.shift() ?? "tasks-todo";

    if("tags"===type) return pinTags_();
    if("custom_fields"===type) return pinCustomFields_();
    if("sections"===type) return pinSections_();

    if("tasks-todos"===type) return todo_();
    if("tasks-favorites"===type) return list_(true);
    if("tasks-all"===type) return list_(false);
})(argvs.shift())
.then(process.exit)
.catch(pipe(console.error, process.exit.bind(process, 1)));

function completion_bash(){
    //#region …
    const cmd= argvs.shift();
    if("--help"===cmd){
        console.log(`Add 'eval "$(${script_name} completion_bash)"' to your '.bashrc' file.`);
        process.exit(0);
    }
    if("--complete"!==cmd){
        console.log("__asana_cli_opts()\n{\n");
        console.log(` COMPREPLY=( $(${script_name} completion_bash --complete "\${#COMP_WORDS[@]}" "\${COMP_WORDS[COMP_CWORD]}" "\${COMP_WORDS[COMP_CWORD-1]}" "\${COMP_WORDS[1]}") )`);
        console.log("return 0\n}");
        console.log(`complete -o filenames -F __asana_cli_opts ${script_name}`);
        process.exit(0);
    }
    const [ level, now, prev, first ]= argvs;
    const options= [ "list", "api", "alias", "abbreviate", "auth", "marks" ];
    const matches= arr=> arr.filter(item=> item.indexOf(now)===0).join(" ");
    if(level==2){
        console.log(matches(Object.keys(configRead().aliases).filter(v=> v[0]==="_"))+" "+matches(options));
        process.exit(0);
    }
    if("marks"===prev){
        console.log(matches(Object.keys(configRead().marks)));
        process.exit(0);
    }
    if("list"===first){
        if(level==3)
            console.log(matches([ "tasks-todos", "tasks-favorites", "tasks-all", "tags", "custom_fields", "sections" ]));
        else
            console.log(matches([ "--help", "list" ]));
        process.exit(0);
    }
    if("abbreviate"===first){
        if(level==3)
            console.log(matches([ "custom_fields", "tags" ]));
        else
            console.log(matches([ "add", "remove", "list" ]));
        process.exit(0);
    }
    if(first==="alias" && level===3){
        console.log(matches([ "add", "remove", "list" ]));
        process.exit(0);
    }
    console.log(matches(["--help"]));
    process.exit(0);
    //#endregion …
}
function question_(rl, q){ return new Promise(r=> rl.question(q+": ", r)); }
function abbreviate(argvs){
    //#region …
    const [ type= "custom_fields", cmd= "list", name, value= "" ]= argvs;
    const prefix= type==="custom_fields" ? "C" : (type==="tags" ? "T" : "S");
    if("list"===cmd) return alias(prefix, [], ([n,v])=> ([ n.slice(1), v ]));
    return alias(prefix, [ cmd, prefix + name,
        type==="custom_fields" ? '{"'+value.split("=").join('":"')+'"}' : value
    ]);
    //#endregion …
}
function alias(prefix, argvs, m= v=> v){
    //#region …
    const cmd= argvs.shift() ?? "list";
    let name= argvs.shift();
    const config= configRead();
    if("list"===cmd){
        const list= Object.entries(config.aliases).filter(([v])=> v[0]===prefix);
        const pad= Math.max(...list.map(([{ length }])=> length));
        console.log("NAME".padEnd(pad)+"\tVALUE");
        list.map(arr=> m(arr).map((n,i)=> !i ? n.padEnd(pad) : n).join("\t")).forEach(v=> console.log(v));
        return 0;
    }
    if("remove"===cmd){
        Reflect.deleteProperty(config.aliases, name);
        configWrite(config);
        return 0;
    }
    const alias= argvs.join(alias_join);
    if(!alias){
        console.error("Command missing for alias '"+name+"'");
        return 1;
    }
    if(name[0]!==prefix){
        console.log("For aliases prefix '_' is needed to prevent colision with possible future features");
        name= prefix+name;
        console.log(`So new name is: ${name}`);
    }
    config.aliases[name]= alias;
    configWrite(config);
    return 0;
    //#endregion …
}
async function api_(){
    //#region …
    const request= argvs.shift() ?? "--help";
    if("--help"===request){
        console.log("See https://developers.asana.com/docs/asana.");
        console.log("For now only GET options are available.");
        return 0;
    }
    const out= await get_(request);
    console.log(isTTY ? out : JSON.stringify(out));
    return 0;
    //#endregion …
}
async function questionChoose_(rl, options){
    //#region …
    const answers= await question_(rl, "choose from list");
    if(answers==="*") return options;
    return answers.split(" ").flatMap(function(v){
        if(v.indexOf("-")===-1) return [ Number(v) ];
        const [ start, end ]= v.split("-").map(n=> Number(n));
        return Array.from({ length: end-start+1 }).map((_, i)=> i+start);
    });
    //#endregion …
}
/**
 * @param {Interface} rl
 * @param {string[]} options
 * @returns Promise<string>
 */
async function questionCmd_(rl, options){
    //#region …
    const is_colors= isTTY && isTCS;
    let c= 75;
    console.log("\n*** Commands ***" + options.reduce(function(o, curr){
        c+= curr.length;
        if(is_colors) curr= curr.replace(/\[(\w)\]/g, "\x1b[34m$1\x1b[0m");
        if(c<76) return o+" ··· "+curr;
        c-= 75;
        return o+"\n  "+curr;
    }, ""));
    return await question_(rl, f("What now", "blue"));
    //#endregion …
}
/**
 * @param {string} text
 * @param {"blue"|"red"|"green"|"yellow"|"magenta"|"cyan"|"crimson"} color
 * @returns {string}
 */
function f(text, color){
    if(!isTTY || !isTCS) return text;
    const c= JSON.parse('{"red":"\\u001b[31m","green":"\\u001b[32m","yellow":"\\u001b[33m","blue":"\\u001b[34m","magenta":"\\u001b[35m","cyan":"\\u001b[36m","crimson":"\\u001b[38m"}');
    return c[color]+text+"\x1b[0m";
}
async function pinTags_(){
    //#region …
    const spinEnd= spiner();
    const tags= await get_("tags", { qs: { opt_fields: [ "followers", "name" ] } });
    const cmd= argvs.shift() ?? "list";
    if("list"!==cmd) return printList(tags);
    return await shell_(tags);
    
    function filter(name_filter= ""){
        if(!name_filter) return tags;
        return tags.filter(({ name })=> name.indexOf(name_filter)!==-1);
    }
    async function shell_(tags){
        const rl= createInterface({ input: process.stdin, output: process.stdout, historySize: 30 });
        const pinned= Object.keys(configRead().aliases).filter(name=> name[0]==="T").map(name=> name.slice(1));
        spinEnd();
        print();
        while(true){
            const cmd= await questionCmd_(rl, [ "[q]uit", "[f]ilter", "[t]oggle pin (*)" ]);
            if(!cmd) continue;
            try{
                switch(cmd){
                    case "q": rl.close(); return 0;
                    case "f": tags= filter(await question_(rl, "filter by name")); print(); continue;
                    case "t": (await questionChoose_(rl, Object.keys(tags))).map(toggle); print(); continue;
                    default: throw new Error(`Unknown '${cmd}'`);
                }
            } catch(e){
                console.error(e.message+" …exit with 'q'"); continue;
            }
        }
        function toggle(num){
            const { gid, name }= tags[num];
            const index= pinned.indexOf(name);
            const operation= index===-1 ? "add" : "remove";
            const error= abbreviate([ "tags", operation, name, gid ]);
            if(error) throw new Error("Tag operation failed!");
            if(operation==="add") pinned.unshift(name);
            else pinned.splice(index, 1);
            return console.log(`'${operation[0].toUpperCase()+operation.slice(1)} ${name}' successfully done.`);
        }
        function print(){ return console.log("\n"+tags.map(({name}, num)=> `${num}: ${name}${pinned.indexOf(name)===-1?"":"*"}`).join(",\t")); }
    }
    function printList(tags){
        spinEnd();
        const col= t=> t.padEnd(tags[tags.length - 1].gid.length);
        if(isTTY)
            console.log(col("GID")+"\tNAME");
        tags.forEach(({ gid, name })=> console.log(`${col(gid)}\t${name}`));
    }
    //#endregion …
}
async function pinSections_(){
    //#region …
    const spinEnd= spiner();
    const num_workspace= argvs.shift() ?? "list";
    exitHelp(num_workspace);
    const list_workspaces= await user_().then(({ workspaces })=> workspaces);
    if("list"===num_workspace)
        return printList("Workspaces", list_workspaces);
    const data_workspace= list_workspaces[num_workspace];
    
    const projects= await get_("users/me/favorites", { qs: { workspace: data_workspace.gid, resource_type: "project", opt_fields: [ "name", "gid" ] } });
    const list= [];
    for(const project of Object.values(projects)){
        const sections= await get_(`projects/${project.gid}/sections`);
        const pv= { project: project.gid };
        if(!sections.length){
            list.push({ name: project.name, value: JSON.stringify(pv) });
            continue;
        }
        for(const section of Object.values(sections))
            list.push({ name: project.name+" → "+section.name, value: JSON.stringify(Object.assign({}, pv, { section: section.gid })) });
    }
    return await shell_(list);
    
    function filter(name_filter= ""){
        if(!name_filter) return list;
        return Object.values(list).filter(({ name })=> name.indexOf(name_filter)!==-1);
    }
    async function shell_(list_cf){
        const rl= createInterface({ input: process.stdin, output: process.stdout, historySize: 30 });
        const pinned= Object.keys(configRead().aliases).filter(name=> name[0]==="S").map(name=> name.slice(1));
        spinEnd();
        print();
        while(true){
            const cmd= await questionCmd_(rl, [ "[q]uit", "[f]ilter", "[t]oggle pin (*)" ]);
            if(!cmd) continue;
            try{
                switch(cmd){
                    case "q": rl.close(); return 0;
                    case "f": list_cf= filter(await question_(rl, "filter by name")); print(); continue;
                    case "t": (await questionChoose_(rl, Object.keys(list_cf))).map(toggle); print(); continue;
                    default: throw new Error(`Unknown '${cmd}'`);
                }
            } catch(e){
                console.error(e.message+" …exit with 'q'"); continue;
            }
        }
        function toggle(num){
            const { value, name }= list_cf[num];
            const index= pinned.indexOf(name);
            const operation= index===-1 ? "add" : "remove";
            const error= abbreviate([ "sections", operation, name, value ]);
            if(error) throw new Error("Tag operation failed!");
            if(operation==="add") pinned.unshift(name);
            else pinned.splice(index, 1);
            return console.log(`'${operation[0].toUpperCase()+operation.slice(1)} ${name}' successfully done.`);
        }
        function print(){ return console.log("\n"+list_cf.map(({name}, num)=> `\t${pinned.indexOf(name)===-1?"":"*"}${num}: ${name}`).join("\n")); }
    }
    
    function printList(title, list){
        spinEnd();
        if(isTTY)
            console.log(`${title}\nNUM\tNAME\tGID`);
        console.log(list.map(({ name, gid }, num)=> `${num}\t${name}\t${gid}`).join("\n"));
    }
    function exitHelp(num){
        if("--help"!==num) return false;
        spinEnd();
        console.log("HELP");
        process.exit(0);
    }
    //#endregion …
}
async function pinCustomFields_(){
    //#region …
    const spinEnd= spiner();
    const num_workspace= argvs.shift() ?? "list";
    exitHelp(num_workspace);
    const list_workspaces= await user_().then(({ workspaces })=> workspaces);
    if("list"===num_workspace)
        return printList("Workspaces", list_workspaces);
    const data_workspace= list_workspaces[num_workspace];
    
    const list_pre= await get_(`workspaces/${data_workspace.gid}/custom_fields`, { qs: { opt_fields: [ "name", "gid", "enum_options.gid", "enum_options.name", "type" ] } });
    const list= list_pre.flatMap(function({ name: name_main, gid: gid_main, enum_options, type }){
        if(!enum_options) return [ { name: name_main+"_"+type, value: gid_main+"=<%1%>" } ];
        return enum_options.map(({ name, gid })=> ({ name: name_main+"→"+name, value: gid_main+"="+gid }));
    });
    return await shell_(list);
    
    function filter(name_filter= ""){
        if(!name_filter) return list;
        return Object.values(list).filter(({ name })=> name.indexOf(name_filter)!==-1);
    }
    async function shell_(list_cf){
        const rl= createInterface({ input: process.stdin, output: process.stdout, historySize: 30 });
        const pinned= Object.keys(configRead().aliases).filter(name=> name[0]==="C").map(name=> name.slice(1));
        spinEnd();
        print();
        while(true){
            const cmd= await questionCmd_(rl, [ "[q]uit", "[f]ilter", "[t]oggle pin (*)" ]);
            if(!cmd) continue;
            try{
                switch(cmd){
                    case "q": rl.close(); return 0;
                    case "f": list_cf= filter(await question_(rl, "filter by name")); print(); continue;
                    case "t": (await questionChoose_(rl, Object.keys(list_cf))).map(toggle); print(); continue;
                    default: throw new Error(`Unknown '${cmd}'`);
                }
            } catch(e){
                console.error(e.message+" …exit with 'q'"); continue;
            }
        }
        function toggle(num){
            const { value, name }= list_cf[num];
            const index= pinned.indexOf(name);
            const operation= index===-1 ? "add" : "remove";
            const error= abbreviate([ "custom_fields", operation, name, value ]);
            if(error) throw new Error("Tag operation failed!");
            if(operation==="add") pinned.unshift(name);
            else pinned.splice(index, 1);
            return console.log(`'${operation[0].toUpperCase()+operation.slice(1)} ${name}' successfully done.`);
        }
        function print(){ return console.log("\n"+list_cf.map(({name}, num)=> `\t${pinned.indexOf(name)===-1?"":"*"}${num}: ${name}`).join("\n")); }
    }
    
    function printList(title, list){
        spinEnd();
        if(isTTY)
            console.log(`${title}\nNUM\tNAME\tGID`);
        console.log(list.map(({ name, gid }, num)=> `${num}\t${name}\t${gid}`).join("\n"));
    }
    function exitHelp(num){
        if("--help"!==num) return false;
        spinEnd();
        console.log("HELP");
        process.exit(0);
    }
    //#endregion …
}
function todo_(){
    // #region …
    const spinEnd= spiner();
    return user_()
    .then(function({ gid: assignee, workspaces: [ { gid: workspace } ] }){
        const completed_since= "now";
        return get_("tasks", { cache: "max-age=15", qs: { assignee, workspace, completed_since, opt_fields: opt_fields_tasks } });
    })
    .then(async function(data){
        const no_p= { gid: 'no', name: 'No project' }, no_s= { gid: 'no', name: 'No section' };
        const grouped= data.sort(sortByModified).reduce(function(out, data){
            (data.memberships.length ? data.memberships : [ {} ]).forEach(function({ project= no_p, section= no_s }){
                const p= project.gid;
                if(!out[p])
                    out[p]=Object.assign({}, project, { sections: {} });
                const s= section.gid;
                if(!out[p].sections[s])
                    out[p].sections[s]= Object.assign({}, section, { list: [] });
                out[p].sections[s].list.push(data);
            });
            return out;
        }, {});
        
        const num_project= argvs.shift() ?? "list";
        exitHelp(num_project);
        const list_projects= Object.entries(grouped);
        if("list"===num_project)
            return printList(`Projects containing tasks to do.`, list_projects);
        const data_project= list_projects[num_project][1];
        
        const num_section= argvs.shift() ?? "list";
        exitHelp(num_section);
        const list_sections= Object.entries(data_project.sections);
        if("list"===num_section)
            return printList(`Task todo in project '${data_project.name}'`, list_sections);
        const data_section= list_sections[num_section][1];
        
        const num_task= argvs.shift() ?? "mark";
        exitHelp(num_task);
        const list_tasks= Object.entries(data_section.list);
        return await tasks_(list_tasks, num_task, data_project, data_section, spinEnd);
        
        function printList(title, list){
            spinEnd();
            if(isTTY)
                console.log(`${title}\nNUM\tNAME\tGID`);
            console.log(list.map(([ , { name, gid } ], num)=> `${num}\t${name}\t${gid}`).join("\n"));
        }
        function exitHelp(num){
            if("--help"!==num) return false;
            spinEnd();
            console.log("HELP");
            process.exit(0);
        }
        function sortByModified({ modified_at: a }, { modified_at: b }){
            const [ aa, bb]= [ a, b ].map(v=> Number(v.replace(/[^0-9]/g, '')));
            return bb-aa;
        }
    });
    // #endregion …
}
async function list_(is_favorites){
    // #region …
    const spinEnd= spiner();
    const num_workspace= argvs.shift() ?? "list";
    exitHelp(num_workspace);
    const list_workspaces= await user_().then(({ workspaces })=> workspaces);
    if("list"===num_workspace)
        return printList("Workspaces", list_workspaces);
    const data_workspace= list_workspaces[num_workspace];

    const num_project= argvs.shift() ?? "list";
    exitHelp(num_project);
    const list_projects= await get_(is_favorites ? `users/me/favorites?workspace=${data_workspace.gid}&resource_type=project` : `workspaces/${data_workspace.gid}/projects`);
    if("list"===num_project)
        return printList(`Projects in '${data_workspace.name}'`, list_projects);
    const data_project= list_projects[num_project];

    const num_section= argvs.shift() ?? "list";
    exitHelp(num_section);
    const list_sections= await get_(`projects/${data_project.gid}/sections`);
    if("list"===num_section)
        return printList(`Sections in '${data_workspace.name}' → '${data_project.name}'`, list_sections);
    const data_section= list_sections[num_section];

    const num_task= argvs.shift() ?? "mark";
    exitHelp(num_task);
    const list_tasks= Object.entries(await get_(`sections/${data_section.gid}/tasks`, { cache: "no-cache", qs: { opt_fields: opt_fields_tasks } }));
    return await tasks_(list_tasks, num_task, data_project, data_section, spinEnd);

    function printList(title, list){
        spinEnd();
        if(isTTY)
            console.log(`${title}\nNUM\tNAME\tGID`);
        console.log(list.map(({ name, gid }, num)=> `${num}\t${name}\t${gid}`).join("\n"));
    }
    function exitHelp(num){
        if("--help"!==num) return false;
        spinEnd();
        console.log("HELP");
        process.exit(0);
    }
    // #endregion …
}
async function marks_(){
    //#region …
    const data_marks= configRead().marks;
    const mark= argvs.shift() ?? "list";
    if("list"===mark){
        if(isTTY)
            console.log("NAME\tDESCRIPTION\tDATE");
        Object.entries(data_marks).forEach(([ name, { description= "—", date= "—" } ])=> console.log(`${name}\t${description}\t${date}`));
        return 0;
    }
    let list_tasks= await getTasks_();
    await shell_(Object.keys(list_tasks), num_task=> taskView_(list_tasks[num_task]));

    function getTasks_(){ return Promise.all(data_marks[mark].tasks.map(gid=> get_(`tasks/${gid}`, { cache: "no-cache", gs: { opt_fields: opt_fields_tasks } }))); }
    async function shell_(options, task_){
        const rl= createInterface({ input: process.stdin, output: process.stdout, historySize: 30 });
        const open_= getOpen();
        while(true){
            print(list_tasks);
            const cmd= await questionCmd_(rl, [ "[q]uit", "[v]iev", "[w]eb", "[c]ustom [f]ields", "[t]ag toggle", "[s]ection (project)" ]);
            if(!cmd) continue;
            try{
                switch(cmd){
                    case "q": rl.close(); return 0;
                    case "v": await Promise.all((await questionChoose_(rl, options)).map(task_)); continue;
                    case "cf": await updateCF_(await questionChoose_(rl, options), rl); continue;
                    case "t": await updateTag_(await questionChoose_(rl, options), rl); continue;
                    case "s": await updateSection_(await questionChoose_(rl, options), rl); continue;
                    case "w": await questionChoose_(rl, options).then(openTaskWeb_); continue;
                    default: throw new Error(`Unknown '${cmd}'`);
                }
            } catch(e){
                console.error(e.message+" …exit with 'q'"); continue;
            }
        }
        function openTaskWeb_(tasks){ return Promise.all(tasks.map(n=> open_(list_tasks[n].permalink_url+"/f"))); }
    }
    async function updateSection_(tasks, rl){
        const aliases= configRead().aliases;
        const aliases_keys= Object.keys(aliases).filter(v=> v[0]==="S");
        console.log("sections: \n  "+aliases_keys.map((v,n)=> n+": "+v.slice(1)).join("\n  "));
        const abb= await question_(rl, "section num");
        if(!abb) return 0;
        const section= configRead().aliases[aliases_keys[abb]];
        if(!section){ console.log("Unknown section"); return 0; }
        const data= JSON.parse(section);
        
        return await Promise.all(tasks.map(async function(num){
            const data_task= list_tasks[num];
            return putPost_(`tasks/${data_task.gid}/addProject`, { qs: { data }, method: "POST" })
            .then(()=> get_(`tasks/${data_task.gid}`, { qs: { opt_fields: opt_fields_tasks_mem } }))
            .then(m=> list_tasks[num].memberships= m.memberships);
        })).catch(console.error);
    }
    async function updateTag_(tasks, rl){
        const aliases= configRead().aliases;
        const aliases_keys= Object.keys(aliases).filter(v=> v[0]==="T");
        console.log("tags: \n  "+aliases_keys.map((v,n)=> n+": "+v.slice(1)).join("\n  "));
        const abb= await question_(rl, "tag num");
        if(!abb) return 0;
        const tag= configRead().aliases[aliases_keys[abb]];
        if(!tag){ console.log("Unknown tag"); return 0; }
        
        return await Promise.all(tasks.map(async function(num){
            const data_task= list_tasks[num];
            const toggle= data_task.tags.find(t=> t.gid===tag) ? "removeTag" : "addTag";
            return putPost_(`tasks/${data_task.gid}/${toggle}`, { qs: { data: { tag } }, method: "POST" })
            .then(()=> get_(`tasks/${data_task.gid}/tags`, { qs: { opt_fields: [ "name", "gid" ] } }))
            .then(tags=> list_tasks[num].tags= tags);
        })).catch(console.error);
    }
    async function updateCF_(tasks, rl){
        const aliases= configRead().aliases;
        const aliases_keys= Object.keys(aliases).filter(v=> v[0]==="C");
        console.log("custom_fields abbreviates: \n  "+aliases_keys.map((v,n)=> n+": "+v.slice(1)).join("\n  "));
        const abb= await question_(rl, "custom_fields num");
        if(!abb) return 0;
        const json_data_pre= configRead().aliases[aliases_keys[abb]];
        if(!json_data_pre){ console.log("Unknown custom_fields"); return 0; }
        
        const json_data= json_data_pre.indexOf("<%1%>")===-1 ? json_data_pre : json_data_pre.replace(/<%1%>/g, await question_(rl, "argument needed"));
        return await Promise.all(tasks.map(async function(num){
            const data_task= list_tasks[num];
            return putPost_("tasks/"+data_task.gid, { qs: { data: { custom_fields: JSON.parse(json_data), opt_fields: opt_fields_tasks } } })
            .then(task=> list_tasks[num]= task);
        })).catch(console.error);
    }
    function print(list_tasks){
        if(isTTY){
            console.log(`NUM\t${"GID".padEnd(list_tasks[list_tasks.length - 1].gid.length)}\tSUBTASKS\tUPDATED\t\tNAME`);
        }
        const pad_subtasks= "subtasks".length;
        console.log(list_tasks
            .map(({ gid, modified_at, num_subtasks= 0, name }, num)=>
                `${num}\t${gid}\t${String(num_subtasks).padEnd(pad_subtasks)}\t${modified_at.split('T')[0]}\t${name}`
            ).join("\n"));
    }
    //#endregion …
}
async function tasks_(list_tasks, num_task, data_project, data_section, spinEnd){
    //#region …
    spinEnd();
    if("mark"===num_task&&isTTY)
        return await shell_(list_tasks.map(([num])=> num), num_task=> taskView_(list_tasks[num_task][1]));
    if("list"===num_task){
        print();
        return 0;
    }
    await taskView_(list_tasks[num_task][1]);

    function print(marked= new Set()){
        if(isTTY){
            console.log(`Task todo in '${data_project.name}' → '${data_section.name}'`);
            console.log(`NUM\t${"GID".padEnd(list_tasks[list_tasks.length - 1][1].gid.length)}\tSUBTASKS\tUPDATED\t\tNAME`);
        }
        const pad_subtasks= "subtasks".length;
        console.log(list_tasks
            .map(([ num, { gid, modified_at, num_subtasks, name } ])=>
                `${marked.has(gid)?"*":""}${num}\t${gid}\t${String(num_subtasks).padEnd(pad_subtasks)}\t${modified_at.split('T')[0]}\t${name}`
            ).join("\n"));
    }
    async function shell_(options, task_){
        const rl= createInterface({ input: process.stdin, output: process.stdout, historySize: 30 });
        let name, description, marked= new Set();
        const marks= configRead().marks;
        currentMarks();
        await editInfo_();
        print(marked);
        while(true){
            const cmd= await questionCmd_(rl, [
                "[q]uit", "[e]dit mark", "[c]urrent [m]arks",
                "[s]ave – append", "[s]ave – [r]eplace",
                "[v]iev task(s)", "[m]ark toggle", "[m]ark toggle ([s]ubtasks)"
            ]);
            if(!cmd) continue;
            try{
                switch(cmd){
                    case "q": rl.close(); return 0;
                    case "v": await Promise.all((await questionChoose_(rl, options)).map(task_)); continue;
                    case "e": await editInfo_(); continue;
                    case "cm": currentMarks(); continue;
                    case "m": markTasks(await questionChoose_(rl, options).then(mapTasks)); continue; 
                    case "ms": await questionChoose_(rl, options).then(markSubtasks_); continue;
                    case "sr":
                    case "s":
                        const c= configRead();
                        if(cmd==="s"&&Reflect.has(c.marks, name)) c.marks[name].tasks.forEach(pipe(marked.add.bind(marked)));
                        Reflect.set(c.marks, name, { description, tasks: Array.from(marked) });
                        configWrite(c);
                        rl.close();
                        return 0;
                }
            } catch(e){
                console.error(e, " …exit with 'q'"); continue;
            }
        }
        function currentMarks(){ console.log("  Current marks names: "+Object.keys(marks).join(", ")); }
        function mapTasks(ts){ return ts.map(t=> list_tasks[t][1].gid); }
        function markSubtasks_(nums_){
            return Promise.all(nums_.map(t=> get_(`tasks/${list_tasks[t][1].gid}/subtasks`, { cache: "no-cache" }))).then(ts=> ts.forEach(t=> markTasks(t.map(({gid})=> gid))));
        }
        function markTasks(tasks){
            tasks.forEach(t=> marked.has(t) ? marked.delete(t) : marked.add(t));
            print(marked);
        }
        async function editInfo_(){
            name= await question_(rl, "Mark name");
            if(Reflect.has(marks, name)) console.log("Mark with this name already exists!");
            description= await question_(rl, "Mark description");
        }
    }
    //#endregion …
}
async function taskView_(data_task){
    //#region …
    const { name, memberships: memberships_pre, gid, custom_fields: custom_fields_pre, modified_at, num_subtasks, permalink_url, tags }= data_task;
    const memberships= memberships_pre.map(o=> Object.values(o).map(o=> o.name).join(" → "));
    const custom_fields= custom_fields_pre.filter(({ enabled })=> enabled).reduce((out, { name, display_value })=> Reflect.set(out, name, display_value) && out, {});
    const out= {
        name,
        memberships,
        gid,
        custom_fields,
        subtasks: (await get_(`tasks/${data_task.gid}/subtasks`, { cache: "no-cache" })).map(({ gid, name })=> ({ gid, name })),
        modified_at,
        tags: tags.map(({ name })=> name),
        permalink_url
    };
    if(isTTY) console.log(out);
    else console.log(JSON.stringify(out));
    //#endregion …
}
function prepareUser(){
    // #region …
    let user;
    return async function(){
        if(user) return user;
        user= await get_("users/me");
        return user;
    };
    // #endregion …
}
async function auth_(){
    //#region …
    console.log("Folows thhis steps:");
    console.log("1. Generates your Personal Access Token (PAT)");
    console.log("	- …there: https://app.asana.com/0/my-apps");
    console.log("	- info there: https://developers.asana.com/docs/personal-access-token");
    console.log("2. copy → paste token");
    const rl= createInterface({ input: process.stdin, output: process.stdout });
    const bearer= (await question_(rl, "…there")).split().reverse().join();
    rl.close();
    if(!bearer){
        console.error("Input empty!");
        return 1;
    }
    writeFileSync(path.bearer, bearer, { encoding: "utf8" });
    console.log("Success");
    //#endregion …
}
function configWrite(config){ return writeFileSync(path.config, JSON.stringify(config, undefined, "  "), { encoding: "utf8" }); }
function configRead(path_manual){
    //#region …
    const path_config= path_manual || path.config;
    let config;
    try{
        config= readFileSync(path_config, { encoding: "utf8" });
    } catch {
        if(existsSync(path_config)){
            console.error(`Config file cannot be read (path: '${path_config}')`);
            process.exit(1);
        }
        config= '{ "options": {}, "aliases": {}, "marks": {} }';
    }
    return JSON.parse(config);
    //#endregion …
}
function scriptsInputs(){
    //#region …
    const [ , name_candidate , ...argvs ]= process.argv;
    const script_name= name_candidate.slice(name_candidate.lastIndexOf("/")+1);
    const config_dir= 
        /* 
            OS X        - '/Users/user/Library/Preferences/asana_cli.json'
            Windows 8   - 'C:\Users\user\AppData\Roaming\asana_cli.json'
            Windows XP  - 'C:\Documents and Settings\user\Application Data\asana_cli.json'
            Linux       - '/home/user/.local/share/asana_cli.json'
        */
        (process.env.APPDATA || (process.env.HOME+(process.platform=='darwin'?'/Library/Preferences':"/.config"))) + "/asana_cli";
    if(!existsSync(config_dir))
        mkdirSync(config_dir, { recursive: true });
    const bearer= config_dir+"/bearer";
    let Authorization;
    try{
        Authorization= "Bearer "+readFileSync(bearer, { encoding: "utf8" }).split().reverse().join();
    } catch {
        if(argvs[0]!=="auth"&&argvs[0]!=="completion_bash"){
            console.error("Missign auth key, please use 'auth' option!");
            process.exit(1);
        }
    }
    const config_path= config_dir+"/asana_cli.json";
    const out= argvs=> ({ path: { config: config_path, bearer }, Authorization, argvs, script_name });
    if(!argvs[0] || "_"!==argvs[0][0])
        return out(argvs);
    const config= configRead(config_path);
    const alias= config.aliases[argvs[0]];
    if(alias)
        return out(alias.split(new RegExp(alias_join, "g")));
    console.error(`Unknown alias '${alias}'`);
    process.exit(1);
    //#endregion …
}
function pipe(...f){ return Array.prototype.reduce.bind(f, (acc, f)=> f(acc)); }
/**
 * @param {string} path
 * @param {object} def
 * @param {"max-age=15"|"max-age=1"|"no-cache"} [def.cache="max-age=1"]
 * @returns Promise<object>
 */
function get_(path, { cache= "max-age=1", qs= {} }= {}){ return new Promise(function(res,rej){
    // #region …
    const params= Object.entries(qs).map(kv => kv.map(encodeURIComponent).join("=")).join("&");
    if(params) path+= "?"+params;
    get("https://app.asana.com/api/1.0/"+path, { headers: { Authorization, "Cache-Control": cache } }, r=> {
        let body= "";
        r.on("data", chunk=> body+= chunk);
        r.on("end", ()=> {
            const { errors, data }= JSON.parse(body);
            if(data) return res(data);
            rej(errors);
        });
    })
    .on("error", rej); });
    // #endregion …
}
/**
 * @param {string} path
 * @param {object} def
 * @param {"max-age=15"|"max-age=1"|"no-cache"} [def.cache="max-age=1"]
 * @param {"PUT"|"POST"} [def.method="PUT"]
 * @returns Promise<object>
 */
function putPost_(path, { cache= "max-age=1", method= "PUT", qs= {} }= {}){ return new Promise(function(res,rej){
    // #region …
    const data= JSON.stringify(qs);
    const req= request({
        host: "app.asana.com",
        path: "/api/1.0/"+path,
        headers: {
            Authorization, "Cache-Control": cache,
            'Content-Length': data.length
        }, method }, r=> {
        let body= "";
        r.on("data", chunk=> body+= chunk);
        r.on("end", ()=> {
            const { errors, data }= JSON.parse(body);
            if(data) return res(data);
            rej(errors);
        });
    });
    req.on("error", rej);
    req.write(data);
    req.end();
    });
    // #endregion …
}
function spiner(){
    // #region …
    if(!isTTY) return ()=> {};
    const spin= (function(s){
        const { length }= s;
        let i= 0;
        return ()=> {
            console.log(`  ${s[i++%length]} loading data from api`);
            moveCursor(process.stdout, 0, -1);
        };
    })([ "⠁", "⠉", "⠙", "⠚", "⠒", "⠂",  "⠂", "⠒", "⠲", "⠴", "⠤", "⠄" ]);
    const i= setInterval(spin, 500);
    return ()=> {
        clearLine(process.stdout);
        clearInterval(i);
    };
    // #endregion …
}
function getOpen(){
    //#region …
    const { platform } = process;
    let opener;
    switch (platform) {
        case 'android':
        case 'linux': opener= ['xdg-open']; break;
        case 'darwin': opener= ['open']; break;
        case 'win32': opener= ['cmd', ['/c', 'start']]; break;
    }
    if(!opener) return ()=> console.error(`Unsupported platform '${platform}'`);
    return url=> new Promise((resolve, reject) => {
        try {
            const [command, args = []]= opener;
            execFileSync( command, [...args, encodeURI(url)]);
            return resolve();
        } catch (error) {
            return reject(error);
        }
    });
    //#endregion …
}
// vim: set tabstop=4 shiftwidth=4 textwidth=250 expandtab :
// vim>60: set foldmethod=marker foldmarker=#region,#endregion :
