/**
 * Common.js
 * Provides a set of common capability for our test suites.
 *
 * AuthLogin()
 * The result of this fn() will be to set a logged in user's
 * Cookie in our cy test runner object.
 *
 * ResetDB()
 * Clears the database back to it's initial starting state, and
 * makes sure our running services reset their Definitions.
 */
const Config = require("./config.js");

var loggedInCookie = null;
// {obj} cypress cookie
// remember the cookie we get back after a Successful Login.

module.exports = {
   AuthLogin: function (cy) {
      if (!loggedInCookie) {
         cy.request("POST", "/auth/login", {
            tenant: Config.tenant,
            email: Config.user.email,
            password: Config.user.password,
         })
            .its("body")
            .as("currentUser");

         cy.getCookie("sails.sid").then((cookie) => {
            loggedInCookie = cookie;
         });
      } else {
         cy.setCookie(loggedInCookie.name, loggedInCookie.value);
      }
   },

   ResetDB: function (cy) {
      //Check environment for alternate stack name
      const stack = Cypress.env("stack");

      // Clear the Physical DB
      cy.exec(`npm run test:reset ${stack}`);

      // Have the running services clear their definitions.
      cy.request("POST", "/test/reset", { tenant: Config.tenant });
   },

   /**
    * run sql files in the test database container
    * @function RunSQL
    * @param {cy} cy cyress instance
    * @param {string} folder pass in the test folder name. (expect sql filed to
    * be in folder/test_setup/sql)
    * @param {string | string[]} files pass in the names of sql files to run
    */
   RunSQL: function (cy, folder, files) {
      const stack = Cypress.env("stack");
      if (typeof files === "string") {
         files = [files];
      }
      cy.exec(
         `node cypress/utils/sql_manager.js ${folder} ${stack} ${files.join(
            " "
         )}`
      );
   },
};
