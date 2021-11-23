#!/usr/bin/env node
import { readFileSync, existsSync, readdirSync, unlinkSync, copyFileSync } from "fs";
import { spawn } from "child_process";
import { join } from "path";
import { env, platform, exit, argv } from "process";

const shared_file_path=
    /*
        OS X        - '/Users/user/Library/Preferences/package_global.json'
        Windows 8   - 'C:\Users\user\AppData\Roaming\package_global.json'
        Windows XP  - 'C:\Documents and Settings\user\Application Data\package_global.json'
        Linux       - '/home/user/.local/share/package_global.json'
     */
    (env.APPDATA || (platform == 'darwin' ? env.HOME + '/Library/Preferences' : env.HOME + "/.local/share"))+'/package_global.json';
if(!existsSync(shared_file_path)){
    console.error(`No '${shared_file_path}' file.`);
    exit(1);
}

const { cordova_keys_store }= JSON.parse(readFileSync(shared_file_path)) || {};
if(!existsSync(shared_file_path)){
    console.error(`No 'cordova_keys_store' key in the shared file '${shared_file_path}'.`);
    exit(1);
}

const [ name, ...params ]= argv.slice(2);
if(!name){
    console.error(`Use one of the options in '\`${shared_file_path}\`.cordova_keys_store'.`);
    console.log("Curently available: "+Object.keys(cordova_keys_store).join(", "));
    exit(1);
}

const /* runtime arguments and cwd */
    { path, password, alias }= cordova_keys_store[name],
    cwd= process.cwd().replace(/\\/g, "/")+"/",
    platform_android= cwd+"platforms/android/",
    platform_build= !existsSync(platform_android+"app/") ? platform_android+"build/" : platform_android+"app/build/",
    apk_dir= platform_build+"outputs/apk/",
    process_clear= params.indexOf("noclear")===-1 && !existsSync(platform+"app/");

console.log("Clering previous builds: start");
if(process_clear) emptyFolder(apk_dir);
console.log("Clering previous builds: end");
console.log(`Temp '${path}': start`);
copyFileSync(path, cwd+"keystore.jks");
console.log(`Temp '${path}': end`);
console.log("Cordova release: start");
const cordova_cmd= spawn("cordova"+( platform==="win32" ? ".cmd" : "" ),
    [ "build", "--release", "android", "--",'--keystore=keystore.jks', "--storePassword="+password, "--password="+password, "--alias="+alias ], { cwd });
cordova_cmd.stderr.pipe(process.stderr);
cordova_cmd.stdout.pipe(process.stdout);
cordova_cmd.stdin.pipe(process.stdin);
cordova_cmd.on("close", function(){
    console.log("Cordova release: end");
    console.log("Cleaning: start");
    unlinkSync(cwd+"keystore.jks");// cordova si to uklada a uz potom bez nej nelze buildit vubec
    unlinkSync(platform_android+"release-signing.properties");
    console.log("Cleaning: end");
});

function emptyFolder(path){
    if(!existsSync(path)) throw new Error(`Path '${path}' doesn’t exist!`);
    readdirSync(path).forEach(file=> unlinkSync(join(path, file)));
}
