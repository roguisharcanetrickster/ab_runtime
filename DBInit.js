#!/usr/bin/env node
//
// DBInit.js
// Run an initial Setup of our Maria DB
//
var async = require("async");
const EventEmitter = require("events");
var path = require("path");
const { spawn } = require("child_process");
var shelljs = require("shelljs");

var dockerProcess;
var logProcess;
var endTrigger = new EventEmitter();

var initBegan = false;

function ProcessData(data) {
    data = data.toString();
    if (!initBegan) {
        if (data.indexOf("initdb.d/01-CreateDBs.sql") > -1) {
            initBegan = true;
            console.log(" initializing tables");
        }
    } else {
        if (data.indexOf("mysqld: ready for connections.") > -1) {
            console.log(" init complete");
            endTrigger.emit("done");
        }
    }
}

async.series(
    [
        (done) => {
            // create a docker process for initializing the DB
            shelljs.exec("docker stack deploy -c dbinit-compose.yml ab");
            console.log(" booting up mysql");
            done();
        },
        (done) => {
            // watch the log entries
            var options = [];
            logProcess = spawn(path.join(__dirname, "logs.js"), options, {
                // stdio: ["ignore", "ignore", "ignore"]
            });
            logProcess.stdout.on("data", ProcessData);
            logProcess.stderr.on("data", ProcessData);
            done();
        },
        (done) => {
            // once we receive our final "ready for connections"
            endTrigger.on("done", () => {
                done();
            });
        },
        (done) => {
            // shut everything down
            console.log(" shutting down");
            logProcess.kill();
            shelljs.exec("docker stack rm ab");
            done();
        }
    ],
    (err) => {
        console.log();
        console.log(" db initialized. ");
        console.log();
        process.exit();
    }
);
