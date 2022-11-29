#!/usr/bin/env node
//
// This is a helper script for refreshing the docker images for the running
// stack.
//
// Use when a new docker image is available for our services.
//
const { exec } = require("child_process");
// const path = require("path");
// const fs = require("fs");

// const cwd = process.cwd();

const stack = " ab";
const stackNoSpace = stack.replace(" ", "");

const hashServices = {};
// {hash}  { imagetag : {serviceData} }
// collect a list of all the running images and their respective containers
// {serviceData} : { ID, NAME, MODE, REPLICAS, IMAGE, PORTS }

const wait = async (mS) => {
   return new Promise((resolve) => {
      setTimeout(() => {
         resolve();
      }, mS);
   });
};

const runCommand = (command) =>
   new Promise((resolve, reject) => {
      exec(command, (error, stdout, stderr) => {
         if (error) {
            reject(error);

            return;
         }

         resolve({ /*error,*/ stdout, stderr });
      });
   });

const dbMigrate = async (branch) => {
   const response = await runCommand(
      `docker run -v ${__dirname}/config/local.js:/app/config/local.js --network=${stackNoSpace}_default digiserve/ab-migration-manager:${branch} node app.js`
   );

   return response;
};

const getServices = async () => {
   const colCommand = "docker service ls";
   const command = `docker service ls | grep ${stack}_`;

   const columns = [];
   // {array} the headers of the columns from the docker service ls command

   try {
      const run = await runCommand(colCommand);
      const colLine = run.stdout.split("\n").shift();

      colLine.split(" ").map((part) => {
         if (part.length > 0) {
            columns.push(part);
         }
      });
   } catch (err) {
      console.error("Error getting service columns:", err);
      throw err;
   }

   try {
      let output = await runCommand(command);

      const lines = output.stdout.split("\n");
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
};

const updateImage = async (services) => {
   if (!services.length) return;

   const pendings = [];

   services.forEach((e) => {
      const command = `docker pull ${e} && echo "" && docker image ls | grep "${
         e.split(":")[0]
      }"`;

      pendings.push(runCommand(command));
   });

   const results = await Promise.all(pendings);

   const response = {
      stdout: "",
      stderr: "",
   };

   results.forEach((e) => {
      response.stdout = `${response.stdout}${e.stdout}\n`;

      if (e.stderr) response.stderr = `${response.stderr}${e.stderr}\n`;
   });

   return response;
};

const updateConfig = async () => {
   const response = await runCommand(
      `docker stack deploy -c config-compose.yml${stack}`
   );

   await wait(5000);

   while (
      !(
         await runCommand(
            `docker service logs${stack}_config | tail -1 | grep "... config preparation complete" || true`
         )
      ).stdout
   )
      await wait(1000);

   return response;
};

const updateDockerCompose = async (services) => {
   if (!services.length) throw new Error("There are no Docker services up.");

   const response = await runCommand(
      `docker stack deploy -c docker-compose.yml -c docker-compose.override.yml${stack}`
   );

   return response;
};

const cleanOldImages = async (services) => {
   if (!services.length) return;

   const pendings = [];

   services.forEach((e) => {
      const command = `docker rmi $(docker images | grep "${e}" | grep "<none>" | awk '{print $3}') -f | true`;

      pendings.push(runCommand(command));
   });

   const results = await Promise.all(pendings);

   const response = {
      stdout: "",
      stderr: "",
   };

   results.forEach((e) => {
      response.stdout = `${response.stdout}${e.stdout}\n`;

      if (e.stderr) response.stderr = `${response.stderr}${e.stderr}\n`;
   });

   return response;
};

const processHandler = async (processName, callbackFunction, ...parameter) => {
   if (!processName)
      throw Error('The parameter "processName" should be "string" type');

   if (!callbackFunction)
      throw Error('The parameter "callbackFunction" should be "function" type');

   console.log(`${processName}:`);
   console.log();

   const response = await callbackFunction(...parameter);

   console.log(response.stdout);

   if (response.stderr) console.log(response.stderr);

   console.log();
};

const Do = async () => {
   try {
      const services = await getServices();
      const listServices = Object.keys(services);

      // our migration image also needs to be updated:
      let branchMigrate = "master";
      if (listServices.length) {
         let ab = listServices.find((s) => s.indexOf("appbuilder") > -1);
         if (ab) {
            branchMigrate = ab.split(":")[1];
            if (!branchMigrate) branchMigrate = "master";
         }
      }
      listServices.unshift(`digiserve/ab-migration-manager:${branchMigrate}`);

      await processHandler("Updating Images", updateImage, listServices);

      await processHandler("Reseting config", updateConfig);

      await processHandler("DB Migrations", dbMigrate, branchMigrate);

      await wait(30000);

      await processHandler(
         "Updating services",
         updateDockerCompose,
         listServices
      );

      await processHandler("Cleaning old images", cleanOldImages, listServices);

      console.log("... done");
      console.log();
   } catch (error) {
      console.error(error);
      console.error();
   }
};

Do();
