#!/usr/bin/env node
//
// This is a helper script for refreshing the docker images for the running
// stack.
//
// Use when a new docker image is available for our services.
// Works with docker swarm or podman compose
//
require("dotenv").config();
/** @type {{ meta_version: string, services: Object.<string, string> }} */
const version = require("./version");
const { exec } = require("child_process");
const path = require("path");
const fs = require("fs").promises;

// const cwd = process.cwd();

const stack = process.env.STACKNAME;
const platform = process.env.PLATFORM === "podman" ? "podman" : "docker";

// const hashServices = {};
// {hash}  { imagetag : {serviceData} }
// collect a list of all the running images and their respective containers
// {serviceData} : { ID, NAME, MODE, REPLICAS, IMAGE, PORTS }

/**
 * Helper to wait a given number of milliseconds
 * @param {number} mS milliseconds to wait
 */
async function wait(mS) {
   return new Promise((resolve) => {
      setTimeout(() => {
         resolve(null);
      }, mS);
   });
}

/**
 * Reads the version from ./version.json and updates env variables.
 * @returns {Promise<string[]>} image names for ab-services with the new tag
 */
async function updateVersion() {
   console.log(`Using meta version ${version.meta_version}`);
   const envPath = path.join(__dirname, ".env");
   let envContent = await fs.readFile(envPath, { encoding: "utf-8" });
   const images = [];
   Object.keys(version.services).forEach((service) => {
      const tag = version.services[service];
      // Image to pull
      images.push(`digiserve/ab-${service.replace(/_/g, "-")}:${tag}`);
      // Update the process env
      const envVar = `AB_${service.toUpperCase()}_VERSION`;
      process.env[envVar] = tag;
      // Update the .env file content
      const regex = new RegExp(`${envVar}=.+`);
      if (regex.test(envContent)) {
         envContent = envContent.replace(regex, `${envVar}=${tag}`);
      } else {
         console.log(`Could not match ${regex.toString()}`);
      }
   });
   await fs.writeFile(envPath, envContent, { encoding: "utf-8" });
   return images;
}

/** @typedef {{stdout:string, stderr: string}} CommandResponse */

/**
 * run a command using child_process.exec
 * @param {string} command
 * @returns {Promise<CommandResponse>}
 */
function runCommand(command) {
   return new Promise((resolve, reject) => {
      exec(command, (error, stdout, stderr) => {
         if (error) {
            reject(error);

            return;
         }

         resolve({ /*error,*/ stdout, stderr });
      });
   });
}

/**
 * run database migrations (from ab-migration manager)
 * @param {string} branch
 */
async function dbMigrate(branch) {
   const response = await runCommand(
      `${platform} run --env-file .env --network=${stack}_default digiserve/ab-migration-manager:${branch} node app.js`
   );

   return response;
}

/**
 * Pull the images
 * @param {string[]} images images to pull
 */
async function updateImage(images) {
   /** @type {Promise<CommandResponse>[]} */
   const pendings = [];

   images.forEach((e) => {
      const command = `${platform} pull ${e} && echo "" && ${platform} image ls | grep "${
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
}

/**
 * update live images
 */
async function updateServices() {
   const command =
      platform === "docker"
         ? `docker stack deploy -c docker-compose.yml -c docker-compose.override.yml ${stack}`
         : `podman compose -f docker-compose.yml -f docker-compose.ovverride.yml -p ${stack} up -d`;
   return await runCommand(command);
}

/**
 * remove old images
 * @param {string[]} images
 */
async function cleanOldImages(images) {
   const pendings = [];

   images.forEach((image) => {
      // discard the tag
      image = image.split(":")[0];
      const command = `${platform} rmi $(${platform} images | grep "${image}" | grep "<none>" | awk '{print $3}') -f`;

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
}

/**
 * call a function and log it's response to the console
 * @param {string} processName Name to log
 * @param {(...args: any[]) => Promise<CommandResponse>} callbackFunction
 * @param {...*} parameter any arguments to pass to the process function
 */
async function processHandler(processName, callbackFunction, ...parameter) {
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
}

async function Do() {
   try {
      // const services = await getServices();
      const images = await updateVersion();
      if (images.length < 1)
         throw new Error("We didn't get any images from updateVersion");

      // our migration image also needs to be updated:
      let branchMigrate = process.env.AB_MIGRATION_MANAGER_VERSION || "master";
      // if (images.length) {
      //    let ab = images.find((s) => s.indexOf("appbuilder") > -1);
      //    if (ab) {
      //       branchMigrate = ab.split(":")[1];
      //       if (!branchMigrate) branchMigrate = "master";
      //    }
      // }
      images.unshift(`digiserve/ab-migration-manager:${branchMigrate}`);

      await processHandler("Updating Images", updateImage, images);

      await processHandler("DB Migrations", dbMigrate, branchMigrate);

      await wait(30000);

      await processHandler("Updating services", updateServices);

      await processHandler("Cleaning old images", cleanOldImages, images);

      console.log("... done");
      console.log();
   } catch (error) {
      console.error(error);
      console.error();
   }
}

Do();
