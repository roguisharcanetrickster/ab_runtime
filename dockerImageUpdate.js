#!/usr/bin/env node
//
// This is a helper script for refreshing the docker images for the running
// stack.
//
// Use when a new docker image is available for our services.
//
const { exec } = require("child_process");
// var path = require("path");
// var fs = require("fs");

// var cwd = process.cwd();

var stack = " ab";

var hashServices = {};
// {hash}  { imagetag : {serviceData} }
// collect a list of all the running images and their respective containers
// {serviceData} : { ID, NAME, MODE, REPLICAS, IMAGE, PORTS }

function runCommand(command) {
   return new Promise((resolve, reject) => {
      exec(command, function (error, stdout, stderr) {
         if (error) {
            console.log(error.stack);
            console.log("Error code: " + error.code);
            console.log("Signal received: " + error.signal);
            return reject(error);
         }
         resolve({ /*error,*/ stdout, stderr });
      });
   });
}

async function getServices() {
   var colCommand = "docker service ls";
   var command = `docker service ls | grep ${stack}_`;

   var columns = [];
   // {array} the headers of the columns from the docker service ls command

   try {
      var run = await runCommand(colCommand);

      var colLine = run.stdout.split("\n").shift();
      colLine.split(" ").map((part) => {
         if (part.length > 0) {
            columns.push(part);
         }
      });

      // console.log("columns:", columns);
   } catch (err) {
      console.error("Error getting service columns:", err);
      throw err;
   }

   try {
      let output = await runCommand(command);

      var lines = output.stdout.split("\n");
      lines.map((line) => {
         let serviceHash = {};
         let index = 0;
         line.split(" ").map((part) => {
            if (part.length > 0) {
               serviceHash[columns[index]] = part;
               index++;
            }
         });
         if (serviceHash["IMAGE"]) {
            hashServices[serviceHash["IMAGE"]] = serviceHash;
         }
      });

      console.log();
      console.log("Found Service Data:");
      console.log(hashServices);
      console.log();
      return hashServices;
   } catch (err) {
      console.error(err);
   }
}

async function updateImage(services) {
   if (services.length == 0) {
      return;
   } else {
      var service = services.shift();
      var command = `docker image pull ${service} `;

      console.log(`... ${command}`);
      try {
         var response = await runCommand(command);
         if (response.error) {
            throw response.error;
         }

         var imageCheck = `docker image ls | grep "${service.split(":")[0]}"`;
         var imageStatus = await runCommand(imageCheck);
         console.log(imageStatus.stdout);
         console.log();

         await updateImage(services);
      } catch (err) {
         console.error("   *** Error pulling service :", service, err);
         throw err;
      }
   }
}

async function updateService(services) {
   if (services.length == 0) {
      return;
   } else {
      var service = services.shift();
      var serviceData = hashServices[service];
      if (!serviceData) {
         var err = new Error(`No service data found for ${service}`);
         console.error(err);
         throw err;
      }
      var serviceName = serviceData["NAME"];
      if (!serviceName) {
         var err2 = new Error(`No service name foud for ${service}`);
         console.error(err2);
         console.error(serviceName);
         throw err2;
      }

      var command = `docker service update --image ${service} ${serviceName}`;

      console.log(`... ${command}`);
      try {
         /* var response = */ await runCommand(command);
         await updateService(services);
      } catch (err) {
         console.error("   *** Error updating service :", service, err);
         throw err;
      }
   }
}

async function Do() {
   var services = await getServices();

   console.log();
   console.log("Updating Images:");
   var listServices = Object.keys(services);
   await updateImage(listServices);

   console.log();
   console.log("Updating running services:");
   listServices = Object.keys(services);
   await updateService(listServices);

   console.log();
   console.log("... done");
}
Do();
