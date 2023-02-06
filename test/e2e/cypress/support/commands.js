// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })
const Config = require("../../../setup/config.js");

Cypress.Commands.add("AuthLogin", () => {
   cy.session("admin", () => {
      cy.log(`Logging in as ${Config.user.email}`);
      cy.request("POST", "/auth/login", {
         tenant: Config.tenant,
         email: Config.user.email,
         password: Config.user.password,
      })
         .its("body")
         .as("currentUser");
   });
});

Cypress.Commands.add("ResetDB", () => {
   const stack = Cypress.env("stack");

   // Clear the Physical DB
   cy.exec(`npm run test:reset ${stack}`);

   // Have the running services clear their definitions.
   cy.request("POST", "/test/reset", { tenant: Config.tenant });
});

Cypress.Commands.add("RunSQL", (folder, files, fail = true) => {
   const stack = Cypress.env("stack");
   if (typeof files === "string") {
      files = [files];
   }

   const regEx = /^\S+/;
   cy.exec(`docker ps | grep ${stack}_db`).then(({ stdout }) => {
      if (!regEx.test(stdout)) {
         throw new Error(`couldn't find process matching '${stack}_db'`);
      }
      const containerId = stdout.match(regEx)[0];

      files.forEach((file) => {
         const path = `./cypress/e2e/${folder}/test_setup/sql/${file}`;

         cy.exec(`docker cp ${path} ${containerId}:/sql/${file}`, {
            log: false,
         });
         cy.exec(
            /* eslint-disable-next-line no-useless-escape*/
            `docker exec ${containerId} bash -c "mysql -u root -proot \"appbuilder-admin\" < ./sql/${file}"`,
            { failOnNonZeroExit: fail }
         );
         cy.exec(`docker exec ${containerId} bash -c "rm ./sql/${file}"`, {
            log: false,
         });
      });
   });
});
