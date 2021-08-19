const Config = require("./config.js");

var loggedInCookie = null;
// {obj} cypress cookie
// remember the cookie we get back after a Successful Login.

module.exports = function(cy) {
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
}