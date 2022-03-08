const shell = require("shelljs");
// Check we have the expected arguments
if (process.argv.length < 5) {
   console.error("Missing expected arguments.");
   console.error("sql_manager folder stack file1 file2 ...");
   process.exit(1);
}
const [, , folder, stack, ...files] = process.argv;

const regEx = /^\S+/;
const response = shell.exec("docker ps", { silent: true }).grep(`${stack}_db`);
if (!regEx.test(response)) {
   console.error(`\ncouldn't find process matching '${stack}_db'`);
   process.exit(1);
}
const containerId = response.stdout.match(regEx)[0];

files.forEach((file) => {
   const path = `./cypress/integration/${folder}/test_setup/sql/${file}`;

   shell.exec(`docker cp ${path} ${containerId}:/sql/${file}`);
   shell.exec(
      /* eslint-disable-next-line no-useless-escape*/
      `docker exec ${containerId} bash -c "mysql -u root -proot \"appbuilder-admin\" < ./sql/${file}"`
   );
   shell.exec(`docker exec ${containerId} bash -c "rm ./sql/${file}"`);
});
